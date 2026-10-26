import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/acknowledge_button.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/permalink_card.dart';
import 'package:matterleast/ui/post_tile.dart';

final _created = DateTime.utc(2026, 10, 26, 9);

PostItem _post({
  String message = 'Morning, all.',
  bool pinned = false,
  bool saved = false,
  DateTime? editAt,
  Map<String, Object?>? metadata,
  String authorUsername = 'wren',
  List<PostPerson> acknowledgedBy = const [],
  DateTime? acknowledgedAt,
}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u1',
  authorName: 'wren',
  authorUsername: authorUsername,
  createAt: _created,
  message: message,
  pinned: pinned,
  saved: saved,
  editAt: editAt,
  metadataJson: metadata == null ? null : jsonEncode(metadata),
  acknowledgedBy: acknowledgedBy,
  acknowledgedAt: acknowledgedAt,
);

Widget _host(Widget child, {bool acknowledgements = false}) => ProviderScope(
  child: MaterialApp(
    theme: MatterleastApp.lightTheme,
    home: Scaffold(
      body: PostEnvironment(
        server: Uri.parse('https://chat.example.test'),
        options: const ParseOptions(),
        myUsername: 'kite',
        onMention: (_) {},
        onChannel: (_) {},
        onLink: (_) {},
        image: (url, size, fit) => SizedBox.fromSize(size: size),
        acknowledgements: acknowledgements,
        child: SingleChildScrollView(child: child),
      ),
    ),
  ),
);

const _askingForAck = {
  'priority': {'priority': 'important', 'requested_ack': true},
};

void main() {
  group('pinned and saved', () {
    for (final (pinned, saved, label) in [
      (true, false, 'Pinned'),
      (false, true, 'Saved'),
      (true, true, 'Pinned and Saved'),
    ]) {
      testWidgets('a message that is $label says so above it', (tester) async {
        await tester.pumpWidget(
          _host(
            PostTile(
              post: _post(pinned: pinned, saved: saved),
              compact: true,
            ),
          ),
        );
        expect(find.text(label), findsOneWidget);
      });
    }

    testWidgets('an ordinary message has no such line', (tester) async {
      await tester.pumpWidget(_host(PostTile(post: _post(), compact: true)));
      for (final label in ['Pinned', 'Saved', 'Pinned and Saved']) {
        expect(find.text(label), findsNothing);
      }
    });
  });

  testWidgets('tapping "(edited)" tells when the message was edited, then '
      'the notice goes', (tester) async {
    final editAt = DateTime.now().subtract(const Duration(minutes: 3));
    await tester.pumpWidget(
      _host(PostTile(post: _post(editAt: editAt), compact: true)),
    );
    await tester.tap(find.text(' (edited)'));
    await tester.pump(const Duration(milliseconds: 300));
    final when = momentLabel(editAt, DateTime.now(), use24: false);
    expect(find.text('Edited $when'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Edited $when'), findsNothing);
  });

  group('acknowledgements', () {
    testWidgets('a message asking for them offers Acknowledge, which '
        'acknowledges', (tester) async {
      var toggled = 0;
      await tester.pumpWidget(
        _host(
          acknowledgements: true,
          PostTile(
            post: _post(metadata: _askingForAck),
            compact: true,
            onAcknowledge: () => toggled++,
          ),
        ),
      );
      await tester.tap(find.text('Acknowledge'));
      expect(toggled, 1);
    });

    testWidgets('a server without acknowledgements shows no button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(PostTile(post: _post(metadata: _askingForAck), compact: true)),
      );
      expect(find.byType(AcknowledgeButton), findsNothing);
    });

    testWidgets('the author sees how many acknowledged instead', (
      tester,
    ) async {
      var toggled = 0;
      await tester.pumpWidget(
        _host(
          acknowledgements: true,
          PostTile(
            post: _post(
              metadata: _askingForAck,
              authorUsername: 'kite',
              acknowledgedBy: [
                (id: 'u2', name: 'heron', username: 'heron', pictureAt: null),
              ],
            ),
            compact: true,
            onAcknowledge: () => toggled++,
          ),
        ),
      );
      expect(find.text('Acknowledge'), findsNothing);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(toggled, 0);
      expect(find.text('heron'), findsOneWidget);
    });

    test('taking one back is allowed for five minutes', () {
      final at = DateTime.utc(2026, 10, 26, 9);
      expect(canUnacknowledge(at, at.add(const Duration(minutes: 4))), isTrue);
      expect(canUnacknowledge(at, at.add(const Duration(minutes: 5))), isFalse);
    });
  });

  group('images in the text', () {
    testWidgets('a tap opens the image', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(
        _host(
          MessageImageOpener(
            open: opened.add,
            child: const MessageImage(
              image: ImagePart('https://images.example.test/wave.gif'),
              measured: ImageSize(width: 200, height: 100),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ImageSlot));
      expect(opened, ['https://images.example.test/wave.gif']);
    });

    testWidgets('one the server did not measure still shows, in a box '
        'reserved before it loads', (tester) async {
      await tester.pumpWidget(
        _host(
          const MessageImage(
            image: ImagePart('https://images.example.test/wave.gif'),
            measured: null,
          ),
        ),
      );
      expect(tester.getSize(find.byType(ImageSlot)), MessageImage.unmeasured);
    });
  });

  test('a linked message is quoted up to 150 characters', () {
    expect(linkedExcerpt('  short  '), 'short');
    final long = 'a' * 200;
    expect(linkedExcerpt(long), '${'a' * 150}…');
  });
}

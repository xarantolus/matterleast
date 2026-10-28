import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/link_preview_card.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';

/// [child] sits in a "message" that has its own long-press, as a post does.
Widget _message(Widget child, {required VoidCallback onMessageHold}) =>
    ProviderScope(
      child: MaterialApp(
        theme: themeForPlatform(MatterleastApp.lightTheme),
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse('https://chat.example.test'),
            options: const ParseOptions(),
            myUsername: 'me',
            onMention: (_) {},
            onChannel: (_) {},
            onLink: (_) {},
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: onMessageHold,
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      ),
    );

void main() {
  late List<String> copied;
  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    copied = [];
    messenger().setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
  });
  tearDown(
    () => messenger().setMockMethodCallHandler(SystemChannels.platform, null),
  );

  Future<void> hold(WidgetTester tester, Offset at) async {
    final gesture = await tester.startGesture(at);
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('holding a link offers only to copy it', (tester) async {
    var messageHeld = false;
    await tester.pumpWidget(
      _message(
        const InlineText(
          inlines: [TextPart('the docs', link: 'https://docs.example.test')],
          style: TextStyle(fontSize: 14),
        ),
        onMessageHold: () => messageHeld = true,
      ),
    );
    await hold(
      tester,
      tester.getCenter(find.textContaining('the docs', findRichText: true)),
    );
    expect(messageHeld, isFalse);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Open'), findsNothing);

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(copied, ['https://docs.example.test']);
  });

  testWidgets('holding a link preview offers only to copy the link', (
    tester,
  ) async {
    var messageHeld = false;
    await tester.pumpWidget(
      _message(
        const LinkPreviewCard(
          preview: LinkPreview(
            url: 'https://docs.example.test/tide',
            title: 'Tide tables',
            siteName: 'Docs',
            description: 'When the water rises.',
          ),
        ),
        onMessageHold: () => messageHeld = true,
      ),
    );
    await hold(tester, tester.getCenter(find.text('Tide tables')));
    expect(messageHeld, isFalse);
    expect(find.byType(ListTile), findsOneWidget);

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(copied, ['https://docs.example.test/tide']);
  });

  testWidgets('holding beside a link still reaches the message', (
    tester,
  ) async {
    var messageHeld = false;
    await tester.pumpWidget(
      _message(
        const InlineText(
          inlines: [
            TextPart('the docs', link: 'https://docs.example.test'),
            TextPart(' and plain words after'),
          ],
          style: TextStyle(fontSize: 14),
        ),
        onMessageHold: () => messageHeld = true,
      ),
    );
    final box = tester.getRect(find.byType(InlineText));
    await hold(tester, box.centerRight - const Offset(8, 0));
    expect(messageHeld, isTrue);
    expect(find.text('Copy link'), findsNothing);
  });
}

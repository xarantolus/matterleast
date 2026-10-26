import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/interactive_message.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';

PostItem _post(Map<String, Object?> props, {String id = 'p1'}) => PostItem(
  id: id,
  key: id,
  userId: 'u1',
  authorName: 'helper',
  createAt: DateTime.utc(2026, 10, 26, 9),
  message: '',
  propsJson: jsonEncode(props),
);

void main() {
  late List<PostActionRequest> sent;
  // A pending answer, or null for one that comes at once.
  Completer<void>? answer;

  setUp(() {
    sent = [];
    answer = null;
  });

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: MatterleastApp.lightTheme,
      home: Scaffold(
        body: PostEnvironment(
          server: Uri.parse('https://chat.example.test'),
          options: const ParseOptions(),
          myUsername: 'river',
          onMention: (_) {},
          onChannel: (_) {},
          onLink: (_) {},
          mmBlocks: true,
          onAction: (r) {
            sent.add(r);
            return answer?.future ?? Future.value();
          },
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );

  Widget integration(PostItem post) => PostIntegration(
    post: post,
    details: PostDetails.decode(post.propsJson, null),
  );

  testWidgets('a button runs its action once until the answer comes', (
    tester,
  ) async {
    final post = _post({
      'attachments': [
        {
          'text': 'Deploy?',
          'actions': [
            {'id': 'ship', 'name': 'Ship it', 'cookie': 'sealed'},
          ],
        },
      ],
    });
    final pending = answer = Completer<void>();
    await pump(tester, integration(post));
    await tester.tap(find.text('Ship it'));
    await tester.pump();
    await tester.tap(find.text('Ship it'));
    await tester.pump();
    expect(sent, hasLength(1));
    expect(sent.single.postId, 'p1');
    expect(sent.single.actionId, 'ship');
    expect(sent.single.cookie, 'sealed');
    expect(sent.single.format, IntegrationFormat.attachment);
    pending.complete();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ship it'));
    await tester.pump();
    expect(sent, hasLength(2), reason: 'it can run again once answered');
  });

  testWidgets('a disabled button does nothing', (tester) async {
    await pump(
      tester,
      integration(
        _post({
          'mm_blocks': [
            {
              'type': 'button',
              'text': 'Closed',
              'action_id': 'x',
              'disabled': true,
            },
          ],
        }),
      ),
    );
    await tester.tap(find.text('Closed'));
    await tester.pump();
    expect(sent, isEmpty);
  });

  testWidgets('a menu sends the chosen value and shows the choice', (
    tester,
  ) async {
    await pump(
      tester,
      integration(
        _post({
          'blocks': [
            {
              'type': 'actions',
              'elements': [
                {
                  'type': 'static_select',
                  'action_id': 'slot',
                  'placeholder': {'type': 'plain_text', 'text': 'Pick a slot'},
                  'options': [
                    {
                      'text': {'type': 'plain_text', 'text': 'Friday'},
                      'value': 'fri',
                    },
                    {
                      'text': {'type': 'plain_text', 'text': 'Monday'},
                      'value': 'mon',
                    },
                  ],
                },
              ],
            },
          ],
          'mm_blocks_actions': 'post-cookie',
        }),
      ),
    );
    await tester.tap(find.text('Pick a slot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monday'));
    await tester.pumpAndSettle();
    expect(sent.single.actionId, 'slot');
    expect(sent.single.selectedOption, 'mon');
    expect(sent.single.cookie, 'post-cookie');
    expect(sent.single.format, IntegrationFormat.block);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Pick a slot'), findsNothing);
  });

  testWidgets('a collapsible section opens on tap', (tester) async {
    await pump(
      tester,
      integration(
        _post({
          'mm_blocks': [
            {
              'type': 'collapsible',
              'header': [
                {'type': 'text', 'text': 'Details'},
              ],
              'content': [
                {'type': 'text', 'text': 'Hidden part'},
              ],
            },
          ],
        }),
      ),
    );
    expect(find.text('Hidden part'), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Hidden part'), findsOneWidget);
  });

  group('inline actions in a message', () {
    Widget text(PostItem post) => PostTextActions(
      post: post,
      details: PostDetails.decode(post.propsJson, null),
      child: PostBody(
        postId: post.id,
        message: 'Please [confirm](mmaction://confirm?step=2) now.',
      ),
    );

    Future<void> tapLink(WidgetTester tester) async {
      final rich = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('confirm'),
      );
      await tester.tapOnText(find.textRange.ofSubstring('confirm'));
      expect(rich, findsOneWidget);
      await tester.pump();
    }

    testWidgets('run in a bot post', (tester) async {
      await pump(tester, text(_post({'from_bot': 'true'})));
      await tapLink(tester);
      expect(sent.single.actionId, 'confirm');
      expect(sent.single.query, {'step': '2'});
      expect(sent.single.postId, 'p1');
    });

    testWidgets("do nothing in a person's post", (tester) async {
      await pump(tester, text(_post({})));
      await tapLink(tester);
      expect(sent, isEmpty);
    });
  });
}

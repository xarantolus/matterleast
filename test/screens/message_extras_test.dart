import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/edit_history_sheet.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/markdown/post_body.dart';

import '../support/builders.dart';
import '../support/fake_server.dart';
import '../support/pump_app.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

PostItem _post(String userId) =>
    postItem(id: 'old1', userId: userId, authorName: 'Sam');

Map<String, Object?> _version(String id, String message, int at) => {
  'id': id,
  'channel_id': channelId,
  'user_id': meId,
  'create_at': 1,
  'edit_at': at,
  'message': message,
};

void main() {
  late ServerHarness h;
  bool? shown;

  Future<void> openMenu(
    WidgetTester tester,
    PostItem post, {
    required Reply? Function(SeenRequest r) handle,
  }) async {
    h = await pumpWithServer(
      tester,
      size: const Size(800, 1600),
      handle: handle,
      seed: (session) => session.outbox.start(),
      overrides: (url) => [
        channelRightsProvider(url, channelId).overrideWith(
          (ref) => Stream.value((
            block: null,
            react: true,
            editOwn: true,
            editOthers: false,
            deleteOwn: true,
            deleteOthers: false,
            channelMentions: true,
            groupMentions: true,
          )),
        ),
      ],
      home: (url) => Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => showMessageMenu(
                  context,
                  MessageTarget(url: url, teamId: teamId, post: post),
                ),
                child: const Text('menu'),
              ),
              TextButton(
                onPressed: () async =>
                    shown = await showEditHistory(context, url, 'old1'),
                child: const Text('history'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('menu'));
    await h.settle(tester);
  }

  Reply? flaggingOn(SeenRequest r) => switch (r.path) {
    '/api/v4/content_flagging/team/$teamId/status' => ok({'enabled': true}),
    '/api/v4/content_flagging/flag/config' => ok({
      'reasons': ['Spam', 'Harassment'],
      'reporter_comment_required': false,
    }),
    '/api/v4/content_flagging/post/old1/flag' => ok({'status': 'OK'}),
    '/api/v4/posts' when r.method == 'POST' => ok({
      'id': 'new1',
      'channel_id': channelId,
      'user_id': meId,
      'create_at': DateTime.now().millisecondsSinceEpoch,
      'message': r.body['message'],
    }),
    _ => ok(const <String, Object?>{}),
  };

  testWidgets('forwarding posts the comment and the link to the channel '
      'picked', (tester) async {
    await openMenu(tester, _post('someone'), handle: flaggingOn);
    await tester.tap(find.text('Forward'));
    await h.settle(tester);
    await tester.tap(find.text('Boats'));
    await h.settle(tester);
    await tester.enterText(find.byType(TextField), 'Look at this');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await h.settle(tester);
    final created = h.server.seen.where(
      (r) => r.method == 'POST' && r.path == '/api/v4/posts',
    );
    expect(created.length, 1);
    expect(created.single.body['channel_id'], channelId);
    expect(
      created.single.body['message'],
      'Look at this\n${h.url}/harbour/pl/old1',
    );
    expect(find.text('Forwarded to Boats'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('forwarding without a comment posts only the link', (
    tester,
  ) async {
    await openMenu(tester, _post('someone'), handle: flaggingOn);
    await tester.tap(find.text('Forward'));
    await h.settle(tester);
    await tester.tap(find.text('Boats'));
    await h.settle(tester);
    await tester.tap(find.byTooltip('Send'));
    await h.settle(tester);
    final created = h.server.seen.where(
      (r) => r.method == 'POST' && r.path == '/api/v4/posts',
    );
    expect(created.single.body['message'], '${h.url}/harbour/pl/old1');
    await h.close(tester);
  });

  testWidgets('a message that was not sent cannot be forwarded', (
    tester,
  ) async {
    await openMenu(
      tester,
      _post('someone').copyWith(sendState: 'failed'),
      handle: flaggingOn,
    );
    expect(find.text('Forward'), findsNothing);
    await h.close(tester);
  });

  testWidgets('Report sends the reason picked and the comment', (tester) async {
    await openMenu(tester, _post('someone'), handle: flaggingOn);
    await tester.tap(find.text('Report'));
    await h.settle(tester);
    await tester.tap(find.text('Harassment'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rude to a colleague');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Report'));
    await h.settle(tester);
    final flag = h.server.seen.singleWhere(
      (r) => r.path == '/api/v4/content_flagging/post/old1/flag',
    );
    expect(flag.body, {
      'reason': 'Harassment',
      'comment': 'Rude to a colleague',
    });
    expect(find.text('Message reported'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('Report is hidden where the server has no content flagging', (
    tester,
  ) async {
    await openMenu(
      tester,
      _post('someone'),
      handle: (r) => r.path.startsWith('/api/v4/content_flagging')
          ? error(501, 'api.content_flagging.disabled')
          : ok(const <String, Object?>{}),
    );
    expect(find.text('Copy text'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
    await h.close(tester);
  });

  testWidgets('Report is not offered on the user\'s own messages', (
    tester,
  ) async {
    await openMenu(tester, _post(meId), handle: flaggingOn);
    expect(find.text('Copy text'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
    await h.close(tester);
  });

  testWidgets('the edit history lists earlier versions and restores one', (
    tester,
  ) async {
    await openMenu(
      tester,
      _post(meId),
      handle: (r) => switch (r.path) {
        '/api/v4/posts/old1/edit_history' => ok([
          _version('v2', 'second try', 1761400000000),
          _version('v1', 'first try', 1761300000000),
        ]),
        '/api/v4/posts/old1/restore/v1' => ok({
          'id': 'old1',
          'channel_id': channelId,
          'user_id': meId,
          'create_at': 1761200000000,
          'edit_at': 1761500000000,
          'message': 'first try',
        }),
        _ => ok(const <String, Object?>{}),
      },
    );
    await tester.tapAt(const Offset(5, 5));
    await h.settle(tester);
    await tester.tap(find.text('history'));
    await h.settle(tester);
    expect(find.text('second try'), findsOneWidget);
    expect(find.text('first try'), findsOneWidget);
    await tester.tap(find.text('Restore').last);
    await h.settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Restore'),
      ),
    );
    await h.settle(tester);
    expect(
      h.server.seen.where(
        (r) => r.method == 'POST' && r.path == '/api/v4/posts/old1/restore/v1',
      ),
      hasLength(1),
    );
    expect(find.text('Version restored'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without edit history on the server "(edited)" has nothing '
      'more to show', (tester) async {
    await openMenu(
      tester,
      _post(meId),
      handle: (r) => r.path.endsWith('/edit_history')
          ? error(404, 'app.post.get.app_error')
          : ok(const <String, Object?>{}),
    );
    await tester.tapAt(const Offset(5, 5));
    await h.settle(tester);
    await tester.tap(find.text('history'));
    await h.settle(tester);
    expect(shown, isFalse);
    expect(find.text('Edit history'), findsNothing);
    await h.close(tester);
  });

  testWidgets('tapping (edited) tells when when there is no history to open', (
    tester,
  ) async {
    var asked = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: EditedMark(
          editAt: DateTime.now(),
          style: null,
          onHistory: () async {
            asked++;
            return false;
          },
        ),
      ),
    );
    await tester.tap(find.text(' (edited)'));
    await tester.pump();
    expect(asked, 1);
    expect(find.textContaining('Edited'), findsOneWidget);
  });
}

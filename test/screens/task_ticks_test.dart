import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/seed.dart';
import '../support/test_session.dart';

const _tasks = '- [ ] buy rope\n- [x] check the lamp';

void main() {
  late ServerHarness h;

  Future<void> open(
    WidgetTester tester, {
    required String author,
    List<String> permissions = const ['create_post', 'edit_post'],
    String? editLimit,
    Duration age = const Duration(minutes: 2),
    Reply Function(SeenRequest)? patch,
  }) async {
    final posted = DateTime.now().subtract(age).millisecondsSinceEpoch;
    h = await pumpWithServer(
      tester,
      size: const Size(900, 700),
      seed: (session) async {
        await seedMyPermissions(session, permissions);
        if (editLimit != null) {
          await session.store.applyConfig('client_config', {
            'PostEditTimeLimit': editLimit,
          });
        }
        await session.store.applyChannelPage(
          channelId: channelId,
          page: api.PostList.fromJson({
            'order': ['t1', 'own'],
            'posts': {
              'own': {
                'id': 'own',
                'channel_id': channelId,
                'user_id': meId,
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 1))
                    .millisecondsSinceEpoch,
                'message': '- [x] control',
              },
              't1': {
                'id': 't1',
                'channel_id': channelId,
                'user_id': author,
                'create_at': posted,
                'message': _tasks,
              },
            },
          }),
          kind: PageKind.page,
          requested: 2,
        );
      },
      handle: (r) {
        if (r.path == '/api/v4/posts/t1/patch' && patch != null) {
          return patch(r);
        }
        if (r.path == '/api/v4/posts/t1/patch') {
          return ok({
            'id': 't1',
            'channel_id': channelId,
            'user_id': author,
            'create_at': posted,
            'edit_at': DateTime.now().millisecondsSinceEpoch,
            'message': r.body['message'],
          });
        }
        if (r.path.endsWith('/posts')) {
          return ok({'order': <String>[], 'posts': <String, Object?>{}});
        }
        return emptyAnswer(r);
      },
      home: (url) => Scaffold(
        body: ConversationView(
          url: url,
          conversation: conversationProvider(url, channelId),
          startText: 'Start',
        ),
      ),
    );
    // My own message is always tickable: once it is, the rights are in.
    await h.settle(
      tester,
      until: () => find.byTooltip('Mark not done').evaluate().isNotEmpty,
    );
  }

  testWidgets('ticking a task of my own message saves the edit and shows it', (
    tester,
  ) async {
    await open(tester, author: meId);
    await tester.tap(find.byTooltip('Mark done'));
    await h.settle(
      tester,
      until: () => h.server.paths.contains('/api/v4/posts/t1/patch'),
    );
    final patch = h.server.seen.firstWhere(
      (r) => r.path == '/api/v4/posts/t1/patch',
    );
    expect(patch.body['message'], '- [x] buy rope\n- [x] check the lamp');
    await h.settle(
      tester,
      until: () => find.byTooltip('Mark not done').evaluate().length == 3,
    );
    expect(find.byTooltip('Mark done'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a failed save puts the box back and says why', (tester) async {
    await open(
      tester,
      author: meId,
      patch: (_) => error(403, 'api.post.update_post.permissions.app_error'),
    );
    await tester.tap(find.byTooltip('Mark done'));
    await h.settle(
      tester,
      until: () => find
          .textContaining('api.post.update_post.permissions.app_error')
          .evaluate()
          .isNotEmpty,
    );
    expect(
      find.textContaining('api.post.update_post.permissions.app_error'),
      findsOneWidget,
    );
    expect(find.byTooltip('Mark done'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('someone else\'s message is ticked only with edit_others_posts', (
    tester,
  ) async {
    await open(tester, author: 'someone');
    expect(find.byTooltip('Mark done'), findsNothing);
    expect(find.byTooltip('Mark not done'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await h.settle(tester);
    expect(h.server.paths, isNot(contains('/api/v4/posts/t1/patch')));
    await h.close(tester);
  });

  testWidgets('with edit_others_posts another one\'s task can be ticked', (
    tester,
  ) async {
    await open(
      tester,
      author: 'someone',
      permissions: const ['create_post', 'edit_post', 'edit_others_posts'],
    );
    expect(find.byTooltip('Mark done'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('after the edit window the boxes are read-only', (tester) async {
    await open(
      tester,
      author: meId,
      editLimit: '600',
      age: const Duration(hours: 1),
    );
    expect(find.byTooltip('Mark done'), findsNothing);
    expect(find.byTooltip('Mark not done'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    await h.close(tester);
  });
}

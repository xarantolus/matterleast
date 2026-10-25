import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> postJson(String id, int hour) => {
  'id': id,
  'channel_id': channelId,
  'user_id': 'someone',
  'create_at': DateTime.utc(2026, 10, 25, hour).millisecondsSinceEpoch,
  'message': 'message $id',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The binding answers every HTTP request with 400; this talks to the fake
  // server for real.
  HttpOverrides.global = null;

  test('a failed older page keeps the reader in place', () async {
    final server = await FakeServer.start();
    final session = await testSession(server);
    final newest = {
      'order': ['n2', 'n1'],
      'posts': {'n2': postJson('n2', 11), 'n1': postJson('n1', 10)},
    };
    await session.store.applyChannelPage(
      channelId: channelId,
      page: api.PostList.fromJson(newest),
      kind: PageKind.page,
      requested: 2,
    );
    server.handle = (r) {
      if (r.path.endsWith('/channels/$channelId/posts')) {
        return r.raw.uri.queryParameters.containsKey('before')
            ? error(500, 'app.post.get_posts.app_error')
            : ok(newest);
      }
      if (r.path.endsWith('/users/ids')) return ok(<Object?>[]);
      return ok(<String, Object?>{});
    };
    final container = ProviderContainer(
      overrides: [
        serverSessionProvider(server.url.toString())
            .overrideWith((ref) async => session),
      ],
    );
    final provider = conversationProvider(server.url.toString(), channelId);
    final sub = container.listen(provider, (_, _) {});
    Future<ConversationState> settled(
      bool Function(ConversationState s) done,
    ) async {
      for (var i = 0; i < 200; i++) {
        final s = container.read(provider);
        if (done(s)) return s;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      fail('state never settled: ${container.read(provider)}');
    }

    final before = await settled(
      (s) => (s.window?.posts.length ?? 0) >= 2 && !s.refreshing,
    );
    container.read(provider.notifier).retryOlder();
    final after = await settled((s) => s.olderFailed && !s.loadingOlder);

    expect(after.generation, before.generation);
    expect(after.intent, before.intent);
    expect(after.saved, before.saved);
    expect(
      [for (final p in after.window!.posts) p.id],
      [for (final p in before.window!.posts) p.id],
    );
    expect(after.refreshFailure, isNull);

    sub.close();
    container.dispose();
    await closeTestSession(session);
    await server.close();
  });
}

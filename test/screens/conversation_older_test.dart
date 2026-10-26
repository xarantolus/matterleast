import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor, QueryInterceptor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';

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

  test(
    'leaving while an older page loads stops watching the messages',
    () async {
      final reads = _PostReads();
      final server = await FakeServer.start();
      final session = await testSession(server, interceptor: reads);
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
      final olderAsked = Completer<void>();
      final release = Completer<void>();
      server.handle = (r) async {
        if (r.path.endsWith('/channels/$channelId/posts')) {
          if (!r.raw.uri.queryParameters.containsKey('before')) {
            return ok(newest);
          }
          olderAsked.complete();
          await release.future;
          return ok({'order': <String>[], 'posts': <String, Object?>{}});
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
      for (var i = 0; i < 200; i++) {
        final s = container.read(provider);
        if ((s.window?.posts.length ?? 0) >= 2 && !s.refreshing) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      container.read(provider.notifier).retryOlder();
      await olderAsked.future.timeout(const Duration(seconds: 5));

      sub.close();
      container.dispose();
      release.complete();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      reads.count = 0;
      await session.db.customUpdate(
        "UPDATE posts SET message = 'edited' WHERE id = 'n2'",
        updates: {session.db.posts},
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(reads.count, 0);
      await closeTestSession(session);
      await server.close();
    },
  );
}

/// Counts reads of the posts table, which only a live watch makes after a
/// plain update.
class _PostReads extends QueryInterceptor {
  var count = 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (statement.contains('"posts"')) count++;
    return super.runSelect(executor, statement, args);
  }
}

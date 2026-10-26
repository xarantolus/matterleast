import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';
import 'package:matterleast/data/views/inbox_views.dart';
import 'package:matterleast/domain/inbox.dart';

import '../support/fake_server.dart';
import 'entry_sync_test.dart' show harbor, lighthouse, recordedServer;

void main() {
  late FakeServer server;
  late ServerDatabase db;
  late ServerStore store;
  late SyncRunner runner;
  late ServerApi http;
  late InboxSync inbox;
  var now = DateTime.utc(2026, 10, 25, 12);

  Reply? inboxServer(SeenRequest r) {
    final path = r.path.replaceFirst('/api/v4', '');
    return switch (path) {
      '/teams/$lighthouse/posts/search' => ok(fixture('mentions')),
      '/teams/$harbor/posts/search' => ok({'order': <Object?>[]}),
      '/users/me/posts/flagged' => ok(fixture('flagged')),
      _ => recordedServer(r),
    };
  }

  setUp(() async {
    server = await FakeServer.start();
    server.handle = inboxServer;
    db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
    store = ServerStore(db);
    runner = SyncRunner();
    http = ServerApi(baseUrl: server.url, token: () => 'token');
    now = DateTime.utc(2026, 10, 25, 12);
    inbox = InboxSync(
      server: http,
      store: store,
      runner: runner,
      users: UserLoader(server: http, store: store),
      clock: () => now,
    );
    await store.applyMe(api.User.fromJson(fixtureMap('me')));
    await store.applyTeams(
      [
        api.Team.fromJson({'id': lighthouse, 'display_name': 'Lighthouse'}),
        api.Team.fromJson({'id': harbor, 'display_name': 'Harbor'}),
      ],
      [
        api.TeamMember.fromJson({'team_id': lighthouse}),
        api.TeamMember.fromJson({'team_id': harbor}),
      ],
    );
  });

  tearDown(() async {
    runner.close();
    http.close();
    await db.close();
    await server.close();
  });

  Future<List<String>> list(String name) async => [
    for (final row
        in await (db.select(db.postLists)
              ..where((l) => l.list.equals(name))
              ..orderBy([(l) => OrderingTerm.asc(l.rank)]))
            .get())
      row.postId,
  ];

  test('mentions are searched per team with the mention keys', () async {
    await inbox.refresh();
    final searches = server.seen.where((r) => r.path.endsWith('/posts/search'));
    expect(searches.map((r) => r.path).toSet(), {
      '/api/v4/teams/$lighthouse/posts/search',
      '/api/v4/teams/$harbor/posts/search',
    });
    for (final r in searches) {
      expect(r.body['terms'], '@alice');
      expect(r.body['is_or_search'], isTrue);
      expect(r.body['per_page'], InboxSync.pageSize);
    }
    final ids = await list(PostListNames.mentions);
    expect(ids, (fixtureMap('mentions')['order']! as List).cast<String>());
    final posts = await (db.select(
      db.posts,
    )..where((p) => p.id.isIn(ids))).get();
    expect(posts, hasLength(ids.length));
    expect(
      await (db.select(db.postRanges)).get(),
      isEmpty,
      reason: 'listed posts are not channel history',
    );
  });

  test('saved messages come from the flagged posts', () async {
    await inbox.refresh();
    expect(await list(PostListNames.saved), ['4imkeyx58tdubfz1ofyok8kfwc']);
  });

  test('fresh lists are not fetched again, forced ones are', () async {
    await inbox.refresh();
    final first = server.seen.length;
    now = now.add(const Duration(minutes: 5));
    await inbox.refresh();
    expect(server.seen.length, first);
    await inbox.refresh(force: true);
    expect(server.seen.length, greaterThan(first));
    server.seen.clear();
    now = now.add(InboxSync.maxAge);
    await inbox.refresh();
    expect(server.paths, contains('/api/v4/users/me/posts/flagged'));
  });

  test('missing authors are fetched so rows show names', () async {
    await inbox.refresh();
    expect(server.paths, contains('/api/v4/users/ids'));
  });

  test('a fetched list replaces the old one in its new order', () async {
    final page = api.PostList.fromJson(fixtureMap('mentions'));
    await store.applyPostList('mentions', page, fetchedAt: now);
    await store.applyPostList(
      'mentions',
      api.PostList(
        order: [page.order[2], page.order[0]],
        posts: {
          page.order[0]: page.posts![page.order[0]]!,
          page.order[2]: page.posts![page.order[2]]!,
        },
      ),
      fetchedAt: now,
    );
    expect(await list('mentions'), [page.order[2], page.order[0]]);
  });

  test('saving elsewhere adds known posts and asks for unknown ones', () async {
    final page = api.PostList.fromJson(fixtureMap('mentions'));
    await store.applyPostList('mentions', page, fetchedAt: now);
    api.Preference flag(String id, String value) => api.Preference.fromJson({
      'category': 'flagged_post',
      'name': id,
      'value': value,
    });
    final missing = await store.applySavedChanges([
      flag(page.order[1], 'true'),
      flag('unknown', 'true'),
    ], deleted: false);
    expect(missing, ['unknown']);
    expect(await list('saved'), [page.order[1]]);
    await store.applySavedChanges([flag(page.order[1], 'true')], deleted: true);
    expect(await list('saved'), isEmpty);
  });

  test('the inbox shows the stored lists once fetched', () async {
    final views = InboxViews(db, serverUrl: 'https://chat.example.test');
    final before = await views.inbox().first;
    expect(before.known, isNot(contains(InboxFilter.mentions)));
    await inbox.refresh();
    final after = await views.inbox().first;
    expect(after.known, containsAll([InboxFilter.mentions, InboxFilter.saved]));
    expect(after.mentions, hasLength(8));
    expect(after.saved.single.postId, '4imkeyx58tdubfz1ofyok8kfwc');
  });
}

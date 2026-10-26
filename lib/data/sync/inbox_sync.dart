import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';

/// Fetches the lists behind Home: recent mentions, saved messages and
/// followed threads. Each is one job per server, coalesced, and is fetched
/// again only when older than [maxAge] unless forced.
class InboxSync {
  InboxSync({
    required this.server,
    required this.store,
    required this.runner,
    required this.users,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final UserLoader users;
  final DateTime Function() _clock;

  static const maxAge = Duration(minutes: 10);
  static const pageSize = 30;
  static const threadsList = 'threads';

  ServerDatabase get _db => store.db;
  api.MattermostClient get _client => server.client;

  /// All three lists; with [force] even when they are fresh.
  Future<void> refresh({
    bool force = false,
    SyncPriority priority = SyncPriority.p2,
  }) async {
    final jobs = <Future<void>>[];
    Future<void> maybe(String list, Future<void> Function() run) async {
      if (!force && !await _stale(list)) return;
      await runner.enqueue(
        SyncJob(key: 'list:$list', priority: priority, run: run),
      );
    }

    jobs
      ..add(maybe(PostListNames.mentions, _mentions))
      ..add(maybe(PostListNames.saved, _saved))
      ..add(maybe(threadsList, _allThreads));
    await Future.wait(jobs);
  }

  Future<void> refreshSaved() =>
      runner.enqueue(SyncJob(key: 'list:${PostListNames.saved}', run: _saved));

  /// One team's followed threads: the newest page and every unread one.
  Future<void> refreshTeamThreads(String teamId) => runner.enqueue(
    SyncJob(
      key: 'threads:$teamId',
      priority: SyncPriority.p0,
      run: () async {
        final unread = await server.call(
          () => _client.threads.getUserThreads(
            userId: 'me',
            teamId: teamId,
            unread: true,
            extended: true,
            perPage: 200,
          ),
        );
        await store.applyThreads(teamId, unread.threads, allUnread: true);
        await _teamThreads(teamId);
        await _missingUsers();
      },
    ),
  );

  Future<bool> _stale(String list) async {
    final at = await _db.syncInt(SyncKeys.listFetchedAt(list));
    return at == null ||
        _clock().difference(DateTime.fromMillisecondsSinceEpoch(at)) >= maxAge;
  }

  Future<List<String>> _teamIds() async => [
    for (final t in await _db.select(_db.myTeams).get()) t.teamId,
  ];

  Future<void> _mentions() async {
    final started = _clock();
    var terms = await _db.syncText(SyncKeys.mentionTerms);
    if (terms == null) {
      await store.applyMe(
        await server.coalesced('me', () => _client.users.getUser(userId: 'me')),
      );
      terms = await _db.syncText(SyncKeys.mentionTerms);
    }
    if (terms == null) return;
    final pages = await Future.wait([
      for (final teamId in await _teamIds())
        server.call(
          () => _client.posts.searchPosts(
            teamId: teamId,
            body: api.ApiV4TeamsTeamIdPostsSearchRequestBody(
              terms: terms!,
              isOrSearch: true,
              timeZoneOffset: started.toLocal().timeZoneOffset.inSeconds,
              perPage: pageSize,
            ),
          ),
        ),
    ]);
    final posts = <String, api.Post>{for (final page in pages) ...?page.posts};
    final order = posts.values.where((p) => p.createAt != null).toList()
      ..sort((a, b) => b.createAt!.compareTo(a.createAt!));
    await store.applyPostList(
      PostListNames.mentions,
      api.PostList(order: [for (final p in order) p.id!], posts: posts),
      fetchedAt: started,
    );
    await _missingUsers();
  }

  Future<void> _saved() async {
    final started = _clock();
    final page = await server.call(
      () =>
          _client.posts.getFlaggedPostsForUser(userId: 'me', perPage: pageSize),
    );
    await store.applyPostList(PostListNames.saved, page, fetchedAt: started);
    await _missingUsers();
  }

  Future<void> _allThreads() async {
    final started = _clock();
    await Future.wait([for (final id in await _teamIds()) _teamThreads(id)]);
    await _db.setSyncInt(
      SyncKeys.listFetchedAt(threadsList),
      started.millisecondsSinceEpoch,
    );
    await _missingUsers();
  }

  Future<void> _teamThreads(String teamId) async {
    final page = await server.call(
      () => _client.threads.getUserThreads(
        userId: 'me',
        teamId: teamId,
        extended: true,
        perPage: pageSize,
      ),
    );
    await store.applyThreads(teamId, page.threads);
    await store.applyUsers([
      for (final t in page.threads)
        for (final u in t.participants)
          if (u.id != null && (u.username?.isNotEmpty ?? false)) u,
    ]);
  }

  /// Authors of listed posts that aren't stored yet, so rows show names.
  Future<void> _missingUsers() async {
    final listed = _db.selectOnly(_db.postLists)
      ..addColumns([_db.postLists.postId]);
    final roots = _db.selectOnly(_db.threads)..addColumns([_db.threads.rootId]);
    final authors = _db.selectOnly(_db.posts, distinct: true)
      ..addColumns([_db.posts.userId])
      ..where(_db.posts.id.isInQuery(listed) | _db.posts.id.isInQuery(roots));
    await users.ensure([
      for (final row in await authors.get()) ?row.read(_db.posts.userId),
    ]);
  }
}

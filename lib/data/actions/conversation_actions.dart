import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_ranges.dart';

/// Fetches the history of an open channel or thread through the sync
/// runner and stores it; the screen follows from the database. Each fetch
/// is coalesced by its key and dropped when [owner] leaves.
class ConversationActions {
  ConversationActions(this.session, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;

  static const pageSize = 60;
  static const aroundSize = 30;

  ServerDatabase get _db => session.db;
  ServerStore get _store => session.store;
  api.MattermostClient get _client => session.api.client;

  Future<void> _run(String key, Object? owner, Future<void> Function() run) =>
      session.runner.enqueue(
        SyncJob(key: key, priority: SyncPriority.p0, owner: owner, run: run),
      );

  Future<T> _call<T>(Future<T> Function() request) => session.api.call(request);

  /// Brings the channel up to date: changes since the last fetch, or the
  /// newest page when nothing is stored. Returns true when more changed
  /// than one answer holds, so the newest page went into a range of its
  /// own and the stored history ends at a gap.
  Future<bool> refreshChannel(String channelId, {Object? owner}) async {
    var capped = false;
    await _run('channel-refresh:$channelId', owner, () async {
      final ranges = await _store.rangesFor('channel', channelId);
      final plan = refreshPlan(
        hasRange: ranges.isNotEmpty,
        postsFetchedAt: await _postsFetchedAt(channelId),
        newestStored: newestRange(ranges)?.latest,
      );
      final crt = await _db.collapsedThreads();
      switch (plan) {
        case FetchNewestPage():
          await _newestPage(channelId, crt);
        case FetchSince(:final since):
          final page = await _call(
            () => _client.posts.getPostsForChannel(
              channelId: channelId,
              since: since.millisecondsSinceEpoch,
              page: null,
              perPage: null,
              collapsedThreads: crt,
              collapsedThreadsExtended: crt,
            ),
          );
          final outcome = await _store.applyChannelPage(
            channelId: channelId,
            page: page,
            kind: PageKind.since,
          );
          if (outcome.capped) {
            capped = true;
            await _newestPage(channelId, crt);
          }
      }
      await _missingUsers(channelId: channelId);
    });
    return capped;
  }

  Future<void> _newestPage(String channelId, bool crt) async {
    final page = await _call(
      () => _client.posts.getPostsForChannel(
        channelId: channelId,
        perPage: pageSize,
        collapsedThreads: crt,
        collapsedThreadsExtended: crt,
      ),
    );
    await _store.applyChannelPage(
      channelId: channelId,
      page: page,
      kind: PageKind.page,
      requested: pageSize,
    );
  }

  /// The page before [oldest] (the oldest message shown).
  Future<void> olderInChannel(
    String channelId, {
    required String oldestId,
    required DateTime oldestAt,
    Object? owner,
  }) => _run('channel-older:$channelId', owner, () async {
    final crt = await _db.collapsedThreads();
    final page = await _call(
      () => _client.posts.getPostsForChannel(
        channelId: channelId,
        before: oldestId,
        perPage: pageSize,
        collapsedThreads: crt,
        collapsedThreadsExtended: crt,
      ),
    );
    await _store.applyChannelPage(
      channelId: channelId,
      page: page,
      kind: PageKind.before,
      anchor: oldestAt,
      requested: pageSize,
    );
    await _missingUsers(channelId: channelId);
  });

  /// The page after [newestId], towards the newest messages.
  Future<void> newerInChannel(
    String channelId, {
    required String newestId,
    required DateTime newestAt,
    Object? owner,
  }) => _run('channel-newer:$channelId', owner, () async {
    final crt = await _db.collapsedThreads();
    final page = await _call(
      () => _client.posts.getPostsForChannel(
        channelId: channelId,
        after: newestId,
        perPage: pageSize,
        collapsedThreads: crt,
        collapsedThreadsExtended: crt,
      ),
    );
    await _store.applyChannelPage(
      channelId: channelId,
      page: page,
      kind: PageKind.after,
      anchor: newestAt,
      requested: pageSize,
    );
    await _missingUsers(channelId: channelId);
  });

  /// The messages around [postId], stored as a range of their own when
  /// they are not next to stored history. Returns the message's time.
  Future<DateTime?> aroundInChannel(
    String channelId,
    String postId, {
    Object? owner,
  }) async {
    DateTime? at;
    await _run('channel-around:$postId', owner, () async {
      final crt = await _db.collapsedThreads();
      final post = await _call(() => _client.posts.getPost(postId: postId));
      at = post.createAt;
      final pages = await Future.wait([
        for (final (before, after) in [(postId, null), (null, postId)])
          _call(
            () => _client.posts.getPostsForChannel(
              channelId: channelId,
              before: before,
              after: after,
              perPage: aroundSize,
              collapsedThreads: crt,
              collapsedThreadsExtended: crt,
            ),
          ),
      ]);
      await _store.applyChannelPage(
        channelId: channelId,
        page: api.PostList(
          order: [...pages[1].order, postId, ...pages[0].order],
          posts: {...?pages[0].posts, ...?pages[1].posts, postId: post},
        ),
        kind: PageKind.around,
      );
      await _missingUsers(channelId: channelId);
    });
    return at;
  }

  Future<void> channelStats(String channelId, {Object? owner}) =>
      session.connection.entry.channelStats(channelId, owner: owner);

  /// The newest replies of a thread, with its first message.
  Future<void> refreshThread(String rootId, {Object? owner}) =>
      _run('thread-refresh:$rootId', owner, () async {
        final crt = await _db.collapsedThreads();
        final page = await _call(
          () => _client.posts.getPostThread(
            postId: rootId,
            perPage: pageSize,
            direction: 'up',
            collapsedThreads: crt,
            collapsedThreadsExtended: crt,
          ),
        );
        await _store.applyThreadPage(
          rootId: rootId,
          page: page,
          reachesStart: !(page.hasNext ?? false),
        );
        await _missingUsers(rootId: rootId);
      });

  Future<void> olderInThread(
    String rootId, {
    required String oldestId,
    required DateTime oldestAt,
    Object? owner,
  }) => _run('thread-older:$rootId', owner, () async {
    final crt = await _db.collapsedThreads();
    final page = await _call(
      () => _client.posts.getPostThread(
        postId: rootId,
        perPage: pageSize,
        fromPost: oldestId,
        fromCreateAt: oldestAt.millisecondsSinceEpoch,
        direction: 'up',
        collapsedThreads: crt,
        collapsedThreadsExtended: crt,
      ),
    );
    await _store.applyThreadPage(
      rootId: rootId,
      page: page,
      kind: PageKind.before,
      reachesStart: !(page.hasNext ?? false),
    );
    await _missingUsers(rootId: rootId);
  });

  /// Marks the thread read up to now, here and on the server.
  Future<void> markThreadRead(String teamId, String rootId) async {
    final now = _clock();
    await _store.applyThreadRead(
      teamId: teamId,
      threadId: rootId,
      lastViewedAt: now,
    );
    await session.runner.enqueue(
      SyncJob(
        key: 'thread-read:$rootId',
        priority: SyncPriority.p0,
        visible: false,
        run: () => _call(
          () => _client.threads.updateThreadReadForUser(
            userId: 'me',
            teamId: teamId,
            threadId: rootId,
            timestamp: '${now.millisecondsSinceEpoch}',
          ),
        ),
      ),
    );
  }

  /// Marks every thread of [teamId] read once the server agreed, as the
  /// Threads list's "Mark all as read" in the official app does.
  Future<void> markAllThreadsRead(String teamId) async {
    // Not in the generated client: no body and an OK answer.
    await _call(
      () => session.api.dio.put<Object?>(
        '/api/v4/users/me/teams/$teamId/threads/read',
      ),
    );
    await _store.applyThreadRead(teamId: teamId, lastViewedAt: _clock());
  }

  Future<DateTime?> _postsFetchedAt(String channelId) async =>
      (await (_db.select(
            _db.myChannels,
          )..where((m) => m.channelId.equals(channelId))).getSingleOrNull())
          ?.postsFetchedAt;

  /// Authors of stored messages in the conversation that aren't stored yet.
  Future<void> _missingUsers({String? channelId, String? rootId}) async {
    final known = _db.selectOnly(_db.users)..addColumns([_db.users.id]);
    final authors = _db.selectOnly(_db.posts, distinct: true)
      ..addColumns([_db.posts.userId])
      ..where(
        (channelId != null
                ? _db.posts.channelId.equals(channelId)
                : _db.posts.rootId.equals(rootId!) |
                      _db.posts.id.equals(rootId)) &
            _db.posts.userId.isNotInQuery(known) &
            _db.posts.userId.equals('').not(),
      );
    await session.users.ensure([
      for (final row in await authors.get()) ?row.read(_db.posts.userId),
    ]);
  }
}

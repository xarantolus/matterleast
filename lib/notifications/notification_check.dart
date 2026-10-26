import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' show Options, ResponseType;
import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/preview_text.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

/// Where the notification check of a server left off: posts at or before
/// [cursorKey] were seen in the app or notified, and [notifiedKey] lists
/// the ids notified lately, so nothing is notified twice.
abstract final class NotifyKeys {
  static const cursorKey = 'notify_cursor';
  static const notifiedKey = 'notify_notified';
}

/// Everything up to [at] counts as seen: the app showed it.
Future<void> markSeen(ServerDatabase db, DateTime at) async {
  final before = await db.syncInt(NotifyKeys.cursorKey) ?? 0;
  if (at.millisecondsSinceEpoch > before) {
    await db.setSyncInt(NotifyKeys.cursorKey, at.millisecondsSinceEpoch);
  }
}

/// Finds what is new on one server and shows or removes its message
/// notifications. The same code runs from the periodic background work
/// (which refreshes unread counts first) and from the stay-connected
/// service (whose WebSocket keeps them current), as one job on the
/// server's sync runner.
class NotificationCheck {
  NotificationCheck(
    this.session,
    this.notifier, {
    required this.appVisible,
    this.serverName,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final Notifier notifier;

  /// While the app is on screen it shows new messages itself.
  final bool Function() appVisible;
  final String? serverName;
  final DateTime Function() _clock;

  String get _url => session.url.toString();
  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  Future<void>? _running;
  var _again = false;

  /// Looks once; with [refresh] the unread counts are fetched first. A call
  /// while a check runs makes it look once more afterwards, so a post that
  /// came in meanwhile is not left for later.
  Future<void> run({bool refresh = true}) {
    if (_running case final running?) {
      _again = true;
      return running;
    }
    final running = _loop(refresh);
    _running = running;
    return running.whenComplete(() => _running = null);
  }

  Future<void> _loop(bool refresh) async {
    do {
      _again = false;
      await session.runner.enqueue(
        SyncJob(
          key: 'notify',
          visible: false,
          timeout: const Duration(seconds: 90),
          run: () => _run(refresh),
        ),
      );
    } while (_again);
  }

  Future<void> _run(bool refresh) async {
    final myId = await _db.syncText(SyncKeys.currentUserId);
    if (myId == null) return;
    final cursorMs = await _db.syncInt(NotifyKeys.cursorKey);
    if (cursorMs == null) {
      // Nothing was seen before, so nothing counts as new yet.
      await markSeen(_db, _clock());
      return;
    }
    final cursor = DateTime.fromMillisecondsSinceEpoch(cursorMs, isUtc: true);
    if (refresh) await _refresh();
    final user = await _user(myId);
    final channels = await _candidates(cursor);
    final pages = <String, api.PostList>{};
    for (final c in channels.values) {
      final since = _later(c.lastViewedAt, cursor.subtract(_lookBack));
      pages[c.id] = await session.api.call(
        () => _client.posts.getPostsForChannel(
          channelId: c.id,
          since: since.millisecondsSinceEpoch,
          page: null,
          perPage: null,
        ),
      );
    }
    final posts = <String, api.Post>{
      for (final page in pages.values) ...?page.posts,
    };
    final threads = await _threads(user.collapsedThreads);
    final notifiable = <(NotifyPost, NotifyKind)>[];
    for (final post in posts.values) {
      final p = _notifyPost(post);
      final channel = p == null ? null : channels[p.channelId];
      if (p == null || channel == null) continue;
      final rootAuthor = p.isReply
          ? posts[p.rootId]?.userId ?? await _authorOf(p.rootId)
          : null;
      final kind = notifyKindOf(
        p,
        channel,
        user,
        thread: NotifyThread(
          following: threads.following.contains(p.rootId),
          rootAuthorIsMe: rootAuthor == myId,
        ),
      );
      if (kind != null) notifiable.add((p, kind));
    }
    final notified = await _notified();
    final updates = conversationUpdates(
      notifiable: notifiable,
      channels: channels,
      cursor: cursor,
      notified: notified.toSet(),
      collapsedThreads: user.collapsedThreads,
      threadsViewedAt: threads.viewedAt,
    );
    if (!appVisible()) {
      for (final update in updates) {
        try {
          await notifier.show(await _notice(update, posts, myId));
        } on Object catch (e) {
          Log.warn('notify', 'Showing a notification failed', e);
        }
      }
    }
    await _db.setSyncText(
      NotifyKeys.notifiedKey,
      jsonEncode(rememberNotified(notified, updates)),
    );
    final newest = posts.values
        .map((p) => p.createAt)
        .whereType<DateTime>()
        .fold(cursor, _later);
    await markSeen(_db, newest);
    await clearRead();
  }

  /// Removes the notifications whose conversation was read elsewhere.
  Future<void> clearRead() async {
    final shown = await notifier.shown(_url);
    if (shown.isEmpty) return;
    final channels = {
      for (final m in await _db.select(_db.myChannels).get())
        m.channelId: m.lastViewedAt,
    };
    final threads = {
      for (final t in await _db.select(_db.threads).get())
        t.rootId: t.lastViewedAt,
    };
    for (final s in readSince(
      shown,
      channelsViewedAt: channels,
      threadsViewedAt: threads,
    )) {
      await notifier.clear(_url, s.key);
    }
  }

  /// How far back a check looks for unread posts to show with new ones.
  static const _lookBack = Duration(hours: 12);

  static DateTime _later(DateTime? a, DateTime b) =>
      a != null && a.isAfter(b) ? a : b;

  /// The unread counts, then the channels of the current team (which
  /// include every direct message) and of teams whose counts changed.
  Future<void> _refresh() async {
    final entry = session.connection.entry;
    final before = {
      for (final t in await _db.select(_db.myTeams).get())
        t.teamId: (t.msgCount, t.mentionCount),
    };
    final unreads = await session.api.call(
      () => _client.teams.getTeamsUnreadForUser(
        userId: 'me',
        includeCollapsedThreads: true,
      ),
    );
    await session.store.applyTeamUnreads(unreads);
    final teams = {
      ?await _db.syncText(SyncKeys.currentTeamId),
      for (final u in unreads)
        if (u.teamId case final id?
            when before[id] != (u.msgCount ?? 0, u.mentionCount ?? 0))
          id,
    };
    final crt = await _db.collapsedThreads();
    await Future.wait([
      for (final team in teams) ...[
        entry.refreshTeam(team, priority: SyncPriority.p1),
        if (crt) entry.unreadThreads(team),
      ],
    ]);
  }

  Future<NotifyUser> _user(String myId) async {
    final me = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(myId))).getSingleOrNull();
    return NotifyUser(
      id: myId,
      username: me?.username ?? '',
      firstName: me?.firstName ?? '',
      props: NotifyProps.fromJsonText(
        await _db.syncText(SyncKeys.accountNotifyProps),
      ),
      collapsedThreads: await _db.collapsedThreads(),
      doNotDisturb: me?.status == 'dnd',
    );
  }

  /// Channels with posts newer than both the cursor and the user's last
  /// visit.
  Future<Map<String, NotifyChannel>> _candidates(DateTime cursor) async {
    final rows =
        await (_db.select(_db.channels).join([
              innerJoin(
                _db.myChannels,
                _db.myChannels.channelId.equalsExp(_db.channels.id),
              ),
            ])..where(
              _db.channels.lastPostAt.isBiggerThanValue(
                cursor.millisecondsSinceEpoch,
              ),
            ))
            .get();
    return {
      for (final row in rows)
        if ((row.readTable(_db.channels), row.readTable(_db.myChannels))
            case (final c, final m)
            when c.deleteAt == null &&
                (m.lastViewedAt == null ||
                    c.lastPostAt!.isAfter(m.lastViewedAt!)))
          c.id: _notifyChannel(c, m),
    };
  }

  static NotifyChannel _notifyChannel(ChannelRow c, MyChannelRow m) {
    final props = NotifyProps.fromJsonText(m.notifyPropsJson).raw;
    return NotifyChannel(
      id: c.id,
      type: c.type,
      lastViewedAt: m.lastViewedAt,
      push: props['push'] ?? 'default',
      muted: props['mark_unread'] == 'mention',
      ignoreChannelMentions: props['ignore_channel_mentions'] == 'on',
    );
  }

  Future<({Set<String> following, Map<String, DateTime> viewedAt})> _threads(
    bool crt,
  ) async {
    if (!crt) return (following: <String>{}, viewedAt: <String, DateTime>{});
    final rows = await _db.select(_db.threads).get();
    return (
      following: {
        for (final t in rows)
          if (t.isFollowing) t.rootId,
      },
      viewedAt: {for (final t in rows) t.rootId: ?t.lastViewedAt},
    );
  }

  Future<String?> _authorOf(String postId) async => (await (_db.select(
    _db.posts,
  )..where((p) => p.id.equals(postId))).getSingleOrNull())?.userId;

  Future<List<String>> _notified() async {
    final text = await _db.syncText(NotifyKeys.notifiedKey);
    if (text == null) return [];
    try {
      final list = jsonDecode(text);
      return list is List ? list.whereType<String>().toList() : [];
    } on FormatException {
      return [];
    }
  }

  static NotifyPost? _notifyPost(api.Post post) {
    final (id, channelId, userId, createAt) = (
      post.id,
      post.channelId,
      post.userId,
      post.createAt,
    );
    if (id == null || channelId == null || userId == null) return null;
    if (createAt == null) return null;
    return NotifyPost(
      id: id,
      channelId: channelId,
      userId: userId,
      createAt: createAt,
      message: post.message ?? '',
      rootId: post.rootId ?? '',
      type: post.type ?? '',
      deleted: post.deleteAt != null,
      fromWebhook: post.props?['from_webhook'] == 'true',
    );
  }

  Future<ConversationNotice> _notice(
    ConversationUpdate update,
    Map<String, api.Post> posts,
    String myId,
  ) async {
    final channel = await (_db.select(
      _db.channels,
    )..where((c) => c.id.equals(update.key.channelId))).getSingle();
    final senders = {for (final p in update.posts) p.userId};
    final partner = channel.type == 'D'
        ? directPartnerId(channel.name, myId)
        : null;
    await session.users.ensure({...senders, ?partner});
    final users = {
      for (final u in await (_db.select(
        _db.users,
      )..where((u) => u.id.isIn({...senders, ?partner}))).get())
        u.id: u,
    };
    final format = await _db.nameFormat();
    String nameOf(String id) => switch (users[id]) {
      final u? => personName((
        username: u.username,
        nickname: u.nickname,
        firstName: u.firstName,
        lastName: u.lastName,
        status: u.status,
      ), format),
      null => 'Someone',
    };
    final channelTitle = switch (channel.type) {
      'D' when partner != null => nameOf(partner),
      _ => channel.displayName.isEmpty ? channel.name : channel.displayName,
    };
    final rootText = update.key.rootId.isEmpty
        ? null
        : previewText(posts[update.key.rootId]?.message ?? '');
    final title = update.key.rootId.isEmpty
        ? channelTitle
        : (rootText?.isNotEmpty ?? false)
        ? 'Thread: $rootText'
        : 'Thread in $channelTitle';
    final avatars = <String, Uint8List?>{};
    for (final id in senders) {
      avatars[id] = await _avatar(id, users[id]?.lastPictureUpdate);
    }
    return ConversationNotice(
      serverUrl: _url,
      key: update.key,
      kind: update.kind,
      title: title,
      group: channel.type != 'D' || update.key.rootId.isNotEmpty,
      teamId: channel.teamId,
      serverName: serverName,
      newestPostId: update.newest.id,
      newestAt: update.newest.createAt,
      messages: [
        for (final p in update.posts)
          NoticeMessage(
            senderId: p.userId,
            senderName: _senderName(posts[p.id], nameOf(p.userId)),
            text: _text(posts[p.id], p.message),
            at: p.createAt,
            avatar: avatars[p.userId],
          ),
      ],
    );
  }

  static final _shortcode = RegExp(r':([a-z0-9_+-]+):');

  /// Webhooks and bots may post under another name.
  static String _senderName(api.Post? post, String fallback) {
    final override = post?.props?['override_username'];
    return post?.props?['from_webhook'] == 'true' &&
            override is String &&
            override.isNotEmpty
        ? override
        : fallback;
  }

  static String _text(api.Post? post, String message) {
    final text = previewText(message)
        .replaceAllMapped(_shortcode, (m) => unicodeForName(m[1]!) ?? m[0]!);
    if (text.isNotEmpty) return text;
    final files = post?.fileIds.length ?? 0;
    if (files == 1) return 'Sent a file';
    if (files > 1) return 'Sent $files files';
    if (post?.props?['attachments'] != null) return 'Sent an attachment';
    return 'Sent a message';
  }

  /// Fetched directly: the image caches keep their index in a database
  /// the plugin shares across the process, which a background engine must
  /// not open and close under the UI.
  Future<Uint8List?> _avatar(String userId, int? pictureUpdate) async {
    try {
      final url = serverUri(session.url, 'api/v4/users/$userId/image', {
        '_': '${pictureUpdate ?? 0}',
      });
      final response = await session.api.call(
        () => session.api.dio.getUri<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        ),
        deadline: const Duration(seconds: 5),
      );
      final bytes = response.data;
      return bytes == null ? null : Uint8List.fromList(bytes);
    } on Object {
      return null;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart' show Options, ResponseType;
import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/preview_text.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/notice_format.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

/// Where the notification check of a server left off: posts at or before
/// [cursorKey] were seen in the app or notified, and [notifiedKey] lists
/// the ids notified lately, so nothing is notified twice.
abstract final class NotifyKeys {
  static const cursorKey = 'notify_cursor';
  static const notifiedKey = 'notify_notified';
}

/// Everything up to [at], by default the newest message stored, counts as
/// seen: the app showed it.
Future<void> markSeen(ServerDatabase db, [DateTime? at]) async {
  final seen = at ?? await newestKnownAt(db);
  if (seen == null) return;
  final before = await db.syncInt(NotifyKeys.cursorKey) ?? 0;
  if (seen.millisecondsSinceEpoch > before) {
    await db.setSyncInt(NotifyKeys.cursorKey, seen.millisecondsSinceEpoch);
  }
}

/// The server time of the newest message this device knows of, stored or
/// reported as a channel's last post.
Future<DateTime?> newestKnownAt(ServerDatabase db) async {
  final last = db.channels.lastPostAt.max();
  final channelMs = await (db.selectOnly(
    db.channels,
  )..addColumns([last])).map((row) => row.read(last)).getSingle();
  final stored = await db.newestPostAt();
  final ms = math.max(channelMs ?? 0, stored?.millisecondsSinceEpoch ?? 0);
  return ms == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// A post as the check needs it, from the server or from the database.
typedef _Seen = ({
  NotifyPost post,
  String? override,
  int files,
  bool attachments,
});

/// Finds what is new on one server and shows or removes its message
/// notifications. The same code runs from the periodic background work
/// (which refreshes unread counts first) and from the live connection of
/// the stay-connected service or the desktop window (whose WebSocket keeps
/// them current), as one job on the server's sync runner.
class NotificationCheck {
  NotificationCheck(
    this.session,
    this.notifier, {
    required this.shownNow,
    this.serverName,
  });

  final ServerSession session;
  final Notifier notifier;

  /// Whether the user sees the conversation in the app now, which then
  /// gets no notification.
  final bool Function(ConversationKey key) shownNow;
  final String? serverName;

  String get _url => session.url.toString();
  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  Future<void>? _running;
  var _again = false;
  var _fetchAgain = false;

  /// Looks once; with [refresh] the unread counts are fetched first. The
  /// posts come from the server unless [fetch] is false, for when the
  /// socket just stored them. A call while a check runs makes it look once
  /// more afterwards, so a post that came in meanwhile is not left for later.
  Future<void> run({bool refresh = true, bool fetch = true}) {
    if (_running case final running?) {
      _again = true;
      _fetchAgain = _fetchAgain || fetch;
      return running;
    }
    final running = _loop(refresh, fetch);
    _running = running;
    return running.whenComplete(() => _running = null);
  }

  Future<void> _loop(bool refresh, bool fetch) async {
    do {
      _again = false;
      final fetchNow = fetch || _fetchAgain;
      _fetchAgain = false;
      await session.runner.enqueue(
        SyncJob(
          key: 'notify',
          visible: false,
          timeout: const Duration(seconds: 90),
          run: () => _run(refresh, fetch: fetchNow),
        ),
      );
    } while (_again);
  }

  Future<void> _run(bool refresh, {required bool fetch}) async {
    final myId = await _db.syncText(SyncKeys.currentUserId);
    if (myId == null) return;
    final cursorMs = await _db.syncInt(NotifyKeys.cursorKey);
    if (cursorMs == null) {
      // Nothing was seen before, so nothing counts as new yet.
      await markSeen(_db);
      return;
    }
    final cursor = DateTime.fromMillisecondsSinceEpoch(cursorMs, isUtc: true);
    if (refresh) await _refresh();
    final user = await _user(myId);
    final channels = await _candidates(cursor);
    final posts = fetch
        ? await _fetchPosts(channels, cursor)
        : await _storedPosts(channels, cursor);
    final threads = await _threads(user.collapsedThreads);
    final notifiable = <(NotifyPost, NotifyKind)>[];
    for (final seen in posts.values) {
      final p = seen.post;
      final channel = channels[p.channelId];
      if (channel == null) continue;
      final rootAuthor = p.isReply
          ? posts[p.rootId]?.post.userId ?? await _authorOf(p.rootId)
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
    for (final update in updates) {
      if (shownNow(update.key)) continue;
      try {
        await notifier.show(
          await _notice(update, posts, myId, sound: user.props.desktopSound),
        );
      } on Object catch (e) {
        Log.warn('notify', 'Showing a notification failed', e);
      }
    }
    await _db.setSyncText(
      NotifyKeys.notifiedKey,
      jsonEncode(rememberNotified(notified, updates)),
    );
    final newest = posts.values
        .map((s) => s.post.createAt)
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
    final props = m.notifyProps;
    return NotifyChannel(
      id: c.id,
      type: c.type,
      lastViewedAt: m.lastViewedAt,
      push: props?.push ?? 'default',
      muted: props?.markUnread == 'mention',
      ignoreChannelMentions: props?.ignoreChannelMentions == 'on',
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

  Future<Map<String, _Seen>> _fetchPosts(
    Map<String, NotifyChannel> channels,
    DateTime cursor,
  ) async {
    final seen = <String, _Seen>{};
    for (final c in channels.values) {
      final since = _since(c, cursor);
      final page = await session.api.call(
        () => _client.posts.getPostsForChannel(
          channelId: c.id,
          since: since.millisecondsSinceEpoch,
          page: null,
          perPage: null,
        ),
      );
      for (final post in page.posts?.values ?? const <api.Post>[]) {
        if (_fromApi(post) case final item?) seen[item.post.id] = item;
      }
    }
    return seen;
  }

  /// What the socket stored, when it has been connected throughout.
  Future<Map<String, _Seen>> _storedPosts(
    Map<String, NotifyChannel> channels,
    DateTime cursor,
  ) async {
    final seen = <String, _Seen>{};
    for (final c in channels.values) {
      final since = _since(c, cursor);
      final rows =
          await (_db.select(_db.posts)..where(
                (p) =>
                    p.channelId.equals(c.id) &
                    p.createAt.isBiggerOrEqualValue(
                      since.millisecondsSinceEpoch,
                    ) &
                    p.sendState.isNull(),
              ))
              .get();
      for (final row in rows) {
        final props = PostDetails.decode(row.propsJson, null).props;
        seen[row.id] = (
          post: NotifyPost(
            id: row.id,
            channelId: row.channelId,
            userId: row.userId,
            createAt: row.createAt,
            message: row.message,
            rootId: row.rootId,
            type: row.type,
            deleted: row.deleteAt != null,
            fromWebhook: props.fromWebhook == 'true',
          ),
          override:
              props.fromWebhook == 'true' &&
                  (props.overrideUsername?.isNotEmpty ?? false)
              ? props.overrideUsername
              : null,
          files: row.fileCount,
          attachments: props.attachments.isNotEmpty,
        );
      }
    }
    return seen;
  }

  static DateTime _since(NotifyChannel c, DateTime cursor) =>
      _later(c.lastViewedAt, cursor.subtract(_lookBack));

  static _Seen? _fromApi(api.Post post) {
    final (id, channelId, userId, createAt) = (
      post.id,
      post.channelId,
      post.userId,
      post.createAt,
    );
    if (id == null || channelId == null || userId == null) return null;
    if (createAt == null) return null;
    final fromWebhook = post.props?['from_webhook'] == 'true';
    final override = post.props?['override_username'];
    return (
      post: NotifyPost(
        id: id,
        channelId: channelId,
        userId: userId,
        createAt: createAt,
        message: post.message ?? '',
        rootId: post.rootId ?? '',
        type: post.type ?? '',
        deleted: post.deleteAt != null,
        fromWebhook: fromWebhook,
      ),
      override: fromWebhook && override is String && override.isNotEmpty
          ? override
          : null,
      files: post.fileIds.length,
      attachments: post.props?['attachments'] != null,
    );
  }

  Future<ConversationNotice> _notice(
    ConversationUpdate update,
    Map<String, _Seen> posts,
    String myId, {
    required bool sound,
  }) async {
    final row = await (_db.select(_db.channels).join([
      innerJoin(
        _db.myChannels,
        _db.myChannels.channelId.equalsExp(_db.channels.id),
      ),
    ])..where(_db.channels.id.equals(update.key.channelId))).getSingle();
    final channel = row.readTable(_db.channels);
    final senders = {for (final p in update.posts) p.userId};
    final partner = channel.type == 'D'
        ? directPartnerId(channel.name, myId)
        : null;
    await session.users.ensure({...senders, ?partner});
    final users = {
      for (final u in await (_db.select(
        _db.users,
      )..where((u) => u.id.isIn({...senders, ?partner, myId}))).get())
        u.id: u,
    };
    final people = <String, PersonInput>{
      for (final u in users.values)
        u.id: (
          username: u.username,
          nickname: u.nickname,
          firstName: u.firstName,
          lastName: u.lastName,
          status: u.status,
        ),
    };
    final format = await _db.nameFormat();
    String nameOf(String id) => switch (people[id]) {
      final p? => personName(p, format),
      null => 'Someone',
    };
    final heading = noticeHeading(
      channelType: channel.type,
      name: conversationName(
        channelInputOf(channel, row.readTable(_db.myChannels)),
        myId: myId,
        people: people,
        nameFormat: format,
      ).title,
      thread: update.key.rootId.isNotEmpty,
    );
    final avatars = <String, Uint8List?>{};
    for (final id in {...senders, ?partner}) {
      avatars[id] = await _avatar(id, users[id]?.lastPictureUpdate);
    }
    return ConversationNotice(
      serverUrl: _url,
      key: update.key,
      kind: update.kind,
      title: heading.title,
      group: heading.group,
      largeIcon: avatars[partner],
      sound: sound,
      teamId: channel.teamId,
      teamName: await _teamName(channel),
      serverName: serverName,
      newestPostId: update.newest.id,
      newestAt: update.newest.createAt,
      messages: [
        for (final p in update.posts)
          if (posts[p.id]?.override case final override)
            NoticeMessage(
              // Android puts consecutive messages of one key under one name.
              senderId: override == null ? p.userId : '${p.userId}/$override',
              senderName: override ?? nameOf(p.userId),
              text: _text(posts[p.id], p.message),
              at: p.createAt,
              avatar: avatars[p.userId],
            ),
      ],
    );
  }

  static final _shortcode = RegExp(r':([a-z0-9_+-]+):');

  static String _text(_Seen? post, String message) {
    final text = previewText(message)
        .replaceAllMapped(_shortcode, (m) => unicodeForName(m[1]!) ?? m[0]!);
    if (text.isNotEmpty) return text;
    final files = post?.files ?? 0;
    if (files == 1) return 'Sent a file';
    if (files > 1) return 'Sent $files files';
    if (post?.attachments ?? false) return 'Sent an attachment';
    return 'Sent a message';
  }

  final _avatars = <(String, int), Uint8List>{};

  Future<Uint8List?> _avatar(String userId, int? pictureUpdate) async {
    final key = (userId, pictureUpdate ?? 0);
    if (_avatars[key] case final cached?) return cached;
    final fetched = await _fetchAvatar(userId, pictureUpdate);
    if (fetched != null) _avatars[key] = fetched;
    return fetched;
  }

  /// Fetched directly: the image caches keep their index in a database
  /// the plugin shares across the process, which a background engine must
  /// not open and close under the UI.
  Future<Uint8List?> _fetchAvatar(String userId, int? pictureUpdate) async {
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
      return bytes == null ? null : roundAvatar(Uint8List.fromList(bytes));
    } on Object {
      return null;
    }
  }

  /// A channel's team, named only when the user is in more than one.
  Future<String?> _teamName(ChannelRow channel) async {
    if (channel.teamId.isEmpty) return null;
    final count = _db.myTeams.teamId.count();
    final teams = await (_db.selectOnly(
      _db.myTeams,
    )..addColumns([count])).map((r) => r.read(count)).getSingle();
    if ((teams ?? 0) < 2) return null;
    final team = await (_db.select(
      _db.teams,
    )..where((t) => t.id.equals(channel.teamId))).getSingleOrNull();
    return team?.displayName;
  }
}

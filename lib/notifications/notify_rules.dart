import 'package:matterleast/domain/channel_mentions.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/panes.dart';

/// Which Android channel a message notification goes to. The order is the
/// importance: a conversation with a mention in it is a mention.
enum NotifyKind { other, thread, direct }

/// A post as far as the notification rules need it.
class NotifyPost {
  const NotifyPost({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.createAt,
    required this.message,
    this.rootId = '',
    this.type = '',
    this.deleted = false,
    this.fromWebhook = false,
  });

  final String id;
  final String channelId;
  final String userId;
  final DateTime createAt;
  final String message;
  final String rootId;
  final String type;
  final bool deleted;
  final bool fromWebhook;

  bool get isReply => rootId.isNotEmpty;
}

/// The user's membership of a channel, as far as notifications care.
class NotifyChannel {
  const NotifyChannel({
    required this.id,
    required this.type,
    this.lastViewedAt,
    this.push = 'default',
    this.muted = false,
    this.ignoreChannelMentions = false,
  });

  final String id;

  /// `O`, `P`, `D` or `G`.
  final String type;
  final DateTime? lastViewedAt;

  /// The channel's own `push` level: `default`, `all`, `mention` or `none`.
  final String push;
  final bool muted;
  final bool ignoreChannelMentions;

  bool get isDirect => type == 'D' || type == 'G';
}

/// Who the user is and what they asked to be told about.
class NotifyUser {
  const NotifyUser({
    required this.id,
    required this.username,
    required this.props,
    this.firstName = '',
    this.collapsedThreads = false,
    this.doNotDisturb = false,
  });

  final String id;
  final String username;
  final String firstName;
  final NotifyProps props;
  final bool collapsedThreads;
  final bool doNotDisturb;
}

/// What is known about the thread a reply belongs to.
class NotifyThread {
  const NotifyThread({this.following = false, this.rootAuthorIsMe = false});

  final bool following;
  final bool rootAuthorIsMe;
}

/// Pure: whether [post] is worth a notification, and of which kind; null
/// when it is not. Follows the server's push rules where the client can
/// know them: the channel's level over the account's, mute, do not disturb,
/// direct messages always, and with collapsed threads replies only in
/// followed threads or when they mention the user.
NotifyKind? notifyKindOf(
  NotifyPost post,
  NotifyChannel channel,
  NotifyUser user, {
  NotifyThread thread = const NotifyThread(),
}) {
  if (post.userId == user.id && !post.fromWebhook) return null;
  if (post.deleted || post.type.startsWith('system_')) return null;
  if (user.doNotDisturb || channel.muted) return null;
  final level = switch (channel.push) {
    'all' => PushLevel.all,
    'mention' => PushLevel.mention,
    'none' => PushLevel.none,
    _ => user.props.push,
  };
  if (level == PushLevel.none) return null;
  if (channel.isDirect) return NotifyKind.direct;
  final mentioned = mentionsUser(
    post.message,
    user,
    channelWide: user.props.channelWide && !channel.ignoreChannelMentions,
  );
  if (mentioned) return NotifyKind.direct;
  if (post.isReply && user.collapsedThreads) {
    return thread.following && user.props.threadReplies
        ? NotifyKind.thread
        : null;
  }
  if (level == PushLevel.all) return NotifyKind.other;
  if (post.isReply) {
    final comments = user.props.raw['comments'] ?? 'never';
    if (comments == 'any' && (thread.following || thread.rootAuthorIsMe) ||
        comments == 'root' && thread.rootAuthorIsMe) {
      return NotifyKind.thread;
    }
  }
  return null;
}

final _code = RegExp(r'```[\s\S]*?(```|$)|`[^`\n]*`');

/// Pure: whether [text] mentions [user] by @username, first name (when the
/// user asked for it), one of their mention words or, with [channelWide],
/// @channel, @all or @here. Code is not prose and never mentions anyone.
bool mentionsUser(String text, NotifyUser user, {required bool channelWide}) {
  if (channelWide && channelWideMention(text) != null) return true;
  final prose = text.replaceAll(_code, ' ');
  final words = <String>[
    '@${user.username}',
    if (user.props.firstName && user.firstName.isNotEmpty) user.firstName,
    if (user.props.usernameMention(user.username)) user.username,
    ...user.props.mentionKeys(user.username),
  ];
  for (final word in words) {
    final escaped = RegExp.escape(word);
    // A word ends where letters, digits or the separators of usernames do.
    final pattern = RegExp(
      '(?<![\\w@])$escaped(?![\\w-]|\\.[\\w])',
      caseSensitive: false,
    );
    if (pattern.hasMatch(prose)) return true;
  }
  return false;
}

/// Where a notification belongs: one per channel, and with collapsed
/// threads one per thread for replies, so opening it lands where the
/// message is.
class ConversationKey {
  const ConversationKey(this.channelId, [this.rootId = '']);

  final String channelId;
  final String rootId;

  static ConversationKey of(
    NotifyPost post, {
    required bool collapsedThreads,
  }) => ConversationKey(
    post.channelId,
    collapsedThreads && post.isReply ? post.rootId : '',
  );

  @override
  bool operator ==(Object other) =>
      other is ConversationKey &&
      other.channelId == channelId &&
      other.rootId == rootId;

  @override
  int get hashCode => Object.hash(channelId, rootId);

  @override
  String toString() => rootId.isEmpty ? channelId : '$channelId/$rootId';
}

/// What one notification shows: its unread messages, oldest first, at
/// least one of them not notified before.
class ConversationUpdate {
  const ConversationUpdate({
    required this.key,
    required this.kind,
    required this.posts,
  });

  final ConversationKey key;
  final NotifyKind kind;
  final List<NotifyPost> posts;

  NotifyPost get newest => posts.last;
}

/// Pure: groups the notifiable unread posts into conversations and keeps
/// those with at least one post not notified before (newer than [cursor]
/// and not in [notified]). Each shows its newest [maxMessages] unread
/// posts. Posts the user already read ([NotifyChannel.lastViewedAt]) are
/// never shown.
List<ConversationUpdate> conversationUpdates({
  required Iterable<(NotifyPost, NotifyKind)> notifiable,
  required Map<String, NotifyChannel> channels,
  required DateTime cursor,
  required Set<String> notified,
  required bool collapsedThreads,
  Map<String, DateTime> threadsViewedAt = const {},
  int maxMessages = 7,
}) {
  final grouped = <ConversationKey, List<(NotifyPost, NotifyKind)>>{};
  for (final entry in notifiable) {
    final (post, _) = entry;
    final viewed = post.isReply && collapsedThreads
        ? threadsViewedAt[post.rootId] ?? channels[post.channelId]?.lastViewedAt
        : channels[post.channelId]?.lastViewedAt;
    if (viewed != null && !post.createAt.isAfter(viewed)) continue;
    final key = ConversationKey.of(post, collapsedThreads: collapsedThreads);
    (grouped[key] ??= []).add(entry);
  }
  final updates = <ConversationUpdate>[];
  for (final MapEntry(:key, value: entries) in grouped.entries) {
    final fresh = entries.where(
      (e) => e.$1.createAt.isAfter(cursor) && !notified.contains(e.$1.id),
    );
    if (fresh.isEmpty) continue;
    final posts = {for (final e in entries) e.$1.id: e.$1}.values.toList()
      ..sort((a, b) => a.createAt.compareTo(b.createAt));
    final kind = entries
        .map((e) => e.$2)
        .reduce((a, b) => a.index >= b.index ? a : b);
    updates.add(
      ConversationUpdate(
        key: key,
        kind: kind,
        posts: posts.length > maxMessages
            ? posts.sublist(posts.length - maxMessages)
            : posts,
      ),
    );
  }
  updates.sort((a, b) => a.newest.createAt.compareTo(b.newest.createAt));
  return updates;
}

/// Pure: the ids to remember as notified after showing [updates], newest
/// last, capped at [keep] so the list never grows without end.
List<String> rememberNotified(
  List<String> before,
  Iterable<ConversationUpdate> updates, {
  int keep = 300,
}) {
  final all = [
    ...before,
    for (final u in updates)
      for (final p in u.posts)
        if (!before.contains(p.id)) p.id,
  ];
  return all.length > keep ? all.sublist(all.length - keep) : all;
}

/// A notification on screen, as its payload describes it.
class ShownConversation {
  const ShownConversation({
    required this.serverUrl,
    required this.key,
    required this.newestAt,
  });

  final String serverUrl;
  final ConversationKey key;
  final DateTime newestAt;
}

/// Pure: the notifications of a server that the user has read since,
/// here or elsewhere: their channel (or thread) was viewed at or after
/// the newest message they show.
List<ShownConversation> readSince(
  Iterable<ShownConversation> shown, {
  required Map<String, DateTime?> channelsViewedAt,
  Map<String, DateTime?> threadsViewedAt = const {},
}) => [
  for (final s in shown)
    if ((s.key.rootId.isEmpty
            ? channelsViewedAt[s.key.channelId]
            : threadsViewedAt[s.key.rootId] ??
                  channelsViewedAt[s.key.channelId])
        case final viewed? when !viewed.isBefore(s.newestAt))
      s,
];

/// Pure: whether the user is looking at the conversation [key] of [url]
/// now, so it needs no notification (Mattermost web's rule): the window
/// has the focus and the conversation is open in it. A thread is open in
/// its own pane or route; anything else in its channel's.
bool conversationInView(
  String url,
  ConversationKey key, {
  required bool focused,
  required Panes open,
}) {
  if (!focused) return false;
  if (key.rootId.isNotEmpty) {
    return switch (open.thread) {
      final t? => t.url == url && t.rootId == key.rootId,
      null => false,
    };
  }
  return switch (open.channel) {
    final c? => c.url == url && c.channelId == key.channelId,
    null => false,
  };
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/preview_text.dart';

part 'inbox.freezed.dart';

/// The chips on Home.
enum InboxFilter { unread, mentions, threads, saved }

enum InboxKind { direct, group, mention, thread, saved }

/// One row of the Home inbox or a threads list.
@freezed
abstract class InboxItem with _$InboxItem {
  const factory InboxItem({
    required String serverUrl,
    required InboxKind kind,
    required String channelId,

    /// The team to show in the rail when the row is opened.
    required String? teamId,
    required String title,

    /// Whose initials the avatar shows.
    required String avatarName,

    /// Who wrote the previewed message; null when the title already says.
    required String? author,
    required String preview,

    /// Where the message is, for rows whose title doesn't say it, such as
    /// `#town-square` for a thread.
    required String? place,
    required DateTime time,

    /// Unread messages or new replies; 0 shows a dot when [unread].
    required int count,
    required bool unread,
    String? postId,
    String? rootId,

    /// Presence of the other person in a direct message.
    String? status,
  }) = _InboxItem;

  const InboxItem._();

  String get key => '$serverUrl/${kind.name}/${postId ?? rootId ?? channelId}';
}

/// One server's rows for every chip, and which lists were fetched at least
/// once, so an empty list can tell "nothing there" from "not known yet".
@freezed
abstract class ServerInbox with _$ServerInbox {
  const factory ServerInbox({
    required List<InboxItem> unread,
    required List<InboxItem> mentions,
    required List<InboxItem> threads,
    required List<InboxItem> saved,
    required Set<InboxFilter> known,
  }) = _ServerInbox;

  const ServerInbox._();

  List<InboxItem> of(InboxFilter filter) => switch (filter) {
    InboxFilter.unread => unread,
    InboxFilter.mentions => mentions,
    InboxFilter.threads => threads,
    InboxFilter.saved => saved,
  };
}

typedef InboxPost = ({
  String id,
  String channelId,
  String rootId,
  String userId,
  DateTime createAt,
  String message,
  bool deleted,
});

typedef InboxThread = ({
  String rootId,
  String channelId,
  String? teamId,
  DateTime? lastReplyAt,
  int unreadReplies,
});

/// A channel the user is in, with its team.
typedef InboxChannel = ({String? teamId, ChannelInput input});

class InboxSource {
  const InboxSource({
    required this.serverUrl,
    required this.myId,
    required this.channels,
    this.currentTeamId,
    this.teams = const {},
    this.people = const {},
    this.posts = const {},
    this.latestPosts = const {},
    this.mentionIds = const [],
    this.savedIds = const [],
    this.threads = const [],
    this.collapsedThreads = false,
    this.nameFormat,
    this.known = const {},
  });

  final String serverUrl;
  final String myId;
  final String? currentTeamId;

  /// By channel id.
  final Map<String, InboxChannel> channels;

  /// Display names by team id.
  final Map<String, String> teams;

  /// By user id.
  final Map<String, PersonInput> people;

  /// Posts of the mention and saved lists and thread roots, by id.
  final Map<String, InboxPost> posts;

  /// The newest stored post per channel, for unread conversations.
  final Map<String, InboxPost> latestPosts;

  /// Newest first, as the server ranked them.
  final List<String> mentionIds;
  final List<String> savedIds;

  /// Followed threads.
  final List<InboxThread> threads;
  final bool collapsedThreads;
  final String? nameFormat;
  final Set<InboxFilter> known;
}

/// Pure: one server's inbox rows from what is stored.
ServerInbox buildServerInbox(InboxSource s) {
  String nameOf(String userId) {
    final person = s.people[userId];
    return person == null ? 'Someone' : personName(person, s.nameFormat);
  }

  String? teamOf(String channelId) {
    final team = s.channels[channelId]?.teamId;
    return (team == null || team.isEmpty) ? s.currentTeamId : team;
  }

  InboxItem postItem(InboxPost post, InboxKind kind, {required bool unread}) {
    final channel = s.channels[post.channelId];
    final c = channel?.input;
    final conversation = c != null && (c.type == 'D' || c.type == 'G');
    final teamName = s.teams[channel?.teamId];
    final title = switch (c) {
      null => 'Unknown channel',
      _ when conversation => conversationName(
        c,
        myId: s.myId,
        people: s.people,
        nameFormat: s.nameFormat,
      ).title,
      _ =>
        teamName == null
            ? '#${c.displayName}'
            : '#${c.displayName} · $teamName',
    };
    final author = nameOf(post.userId);
    return InboxItem(
      serverUrl: s.serverUrl,
      kind: kind,
      channelId: post.channelId,
      teamId: teamOf(post.channelId),
      title: title,
      avatarName: author,
      author: author,
      preview: post.deleted ? '(message deleted)' : previewText(post.message),
      place: null,
      time: post.createAt,
      count: 0,
      unread: unread,
      postId: post.id,
      rootId: post.rootId.isEmpty ? null : post.rootId,
    );
  }

  bool unreadMention(InboxPost post) {
    final c = s.channels[post.channelId]?.input;
    if (c == null || c.type == 'D' || c.type == 'G') return false;
    if (post.userId == s.myId || post.deleted) return false;
    // Under collapsed threads a reply is covered by its thread's row.
    if (s.collapsedThreads && post.rootId.isNotEmpty) return false;
    final viewed = c.lastViewedAt;
    return viewed == null || post.createAt.isAfter(viewed);
  }

  final conversations = <InboxItem>[];
  for (final MapEntry(key: id, value: channel) in s.channels.entries) {
    final c = channel.input;
    if (c.type != 'D' && c.type != 'G') continue;
    final unreadCount = s.collapsedThreads
        ? c.totalMsgCountRoot - c.msgCountRoot
        : c.totalMsgCount - c.msgCount;
    final mentions = s.collapsedThreads ? c.mentionCountRoot : c.mentionCount;
    if (c.archived || ((c.muted || unreadCount <= 0) && mentions <= 0)) {
      continue;
    }
    final name = conversationName(
      c,
      myId: s.myId,
      people: s.people,
      nameFormat: s.nameFormat,
    );
    final latest = s.latestPosts[id];
    final current =
        latest != null &&
        (c.lastPostAt == null || !latest.createAt.isBefore(c.lastPostAt!));
    final count = unreadCount > 0 ? unreadCount : mentions;
    conversations.add(
      InboxItem(
        serverUrl: s.serverUrl,
        kind: c.type == 'D' ? InboxKind.direct : InboxKind.group,
        channelId: id,
        teamId: s.currentTeamId,
        title: name.title,
        avatarName: name.title,
        author: current && c.type == 'G' ? nameOf(latest.userId) : null,
        preview: current
            ? previewText(latest.message)
            : count == 1
            ? '1 new message'
            : '$count new messages',
        place: null,
        time: c.lastPostAt ?? latest?.createAt ?? DateTime.utc(1970),
        count: count,
        unread: true,
        postId: current ? latest.id : null,
        status: name.status,
      ),
    );
  }

  final mentions = [
    for (final id in s.mentionIds)
      if (s.posts[id] case final post?)
        postItem(post, InboxKind.mention, unread: unreadMention(post)),
  ];
  final saved = [
    for (final id in s.savedIds)
      if (s.posts[id] case final post?)
        postItem(post, InboxKind.saved, unread: false),
  ];
  final threads = [
    for (final t in s.threads)
      if (s.posts[t.rootId] case final root?)
        () {
          final c = s.channels[t.channelId]?.input;
          final author = nameOf(root.userId);
          final place = switch (c) {
            null => null,
            _ when c.type == 'D' || c.type == 'G' => conversationName(
              c,
              myId: s.myId,
              people: s.people,
              nameFormat: s.nameFormat,
            ).title,
            _ => '#${c.displayName}',
          };
          return InboxItem(
            serverUrl: s.serverUrl,
            kind: InboxKind.thread,
            channelId: t.channelId,
            teamId: (t.teamId == null || t.teamId!.isEmpty)
                ? teamOf(t.channelId)
                : t.teamId,
            title: author,
            avatarName: author,
            author: null,
            preview: root.deleted
                ? '(message deleted)'
                : previewText(root.message),
            place: place,
            time: t.lastReplyAt ?? root.createAt,
            count: t.unreadReplies,
            unread: t.unreadReplies > 0,
            rootId: t.rootId,
          );
        }(),
  ];
  return ServerInbox(
    unread: sortedNewestFirst([
      ...conversations,
      ...mentions.where((m) => m.unread),
      ...threads.where((t) => t.unread),
    ]),
    mentions: sortedNewestFirst(mentions),
    threads: sortedNewestFirst(threads),
    saved: sortedNewestFirst(saved),
    known: s.known,
  );
}

/// Pure: the rows of [filter] across servers, newest first.
List<InboxItem> mergeInbox(Iterable<ServerInbox> servers, InboxFilter filter) =>
    sortedNewestFirst([for (final server in servers) ...server.of(filter)]);

List<InboxItem> sortedNewestFirst(List<InboxItem> items) =>
    [...items]..sort((a, b) {
      final byTime = b.time.compareTo(a.time);
      return byTime != 0 ? byTime : a.key.compareTo(b.key);
    });

/// Pure: the search terms that find messages mentioning the user, as the
/// official app builds them: their mention keys, their first name when
/// they asked for it, and `@username`; never `@channel`, `@all` or `@here`.
String mentionTerms({
  required String username,
  String firstName = '',
  String? mentionKeys,
  String? firstNameKey,
}) {
  const broadcast = {'@channel', '@all', '@here'};
  final keys = <String>[
    for (final key in (mentionKeys ?? '').split(','))
      if (key.trim().isNotEmpty && !broadcast.contains(key.trim())) key.trim(),
    if (firstNameKey == 'true' && firstName.isNotEmpty) firstName,
  ];
  final own = '@$username';
  if (!keys.contains(own)) keys.add(own);
  return keys.toSet().join(' ');
}

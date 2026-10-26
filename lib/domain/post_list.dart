import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/system_message.dart';

part 'post_list.freezed.dart';

/// Someone a message shows: who reacted or replied.
typedef PostPerson = ({
  String id,
  String name,
  String username,
  int? pictureAt,
});

/// One message as a conversation shows it.
@freezed
abstract class PostItem with _$PostItem {
  const factory PostItem({
    required String id,

    /// Our own unsent post keeps this key when the server id arrives.
    required String key,
    required String userId,
    required String authorName,
    required DateTime createAt,
    required String message,
    @Default('') String type,
    @Default('') String rootId,
    DateTime? editAt,
    @Default(false) bool deleted,

    /// `pending` or `failed` while our own post is unsent.
    String? sendState,
    @Default(0) int replyCount,
    DateTime? lastReplyAt,

    /// Replies in a followed thread the reader hasn't seen.
    @Default(0) int unreadReplies,

    /// The people who replied, newest first, as far as they are known.
    @Default(<PostPerson>[]) List<PostPerson> participants,
    @Default('') String authorUsername,
    @Default(false) bool authorIsBot,
    int? authorPictureAt,

    /// The post's props and metadata as the server sent them; decoded when
    /// the row is drawn.
    String? propsJson,
    String? metadataJson,
    @Default(<ReactionGroup>[]) List<ReactionGroup> reactions,
    @Default(false) bool pinned,

    /// Why the server's copy couldn't be shown, such as an error type; the
    /// row then has no content.
    String? decodeProblem,
  }) = _PostItem;

  const PostItem._();

  bool get isSystem =>
      type.startsWith('system_') && !isEphemeral && !unreadable;
  bool get edited => editAt != null && !deleted;
  bool get isReply => rootId.isNotEmpty;
  bool get isEphemeral => type == 'system_ephemeral';
  bool get unreadable => decodeProblem != null;
}

/// Pure: what "Copy details" puts on the clipboard for a post that
/// couldn't be shown, for a bug report: where it is and what went wrong,
/// never what it says.
String unreadableDetails(PostItem post) => [
  'Message id: ${post.id}',
  if (post.rootId.isNotEmpty) 'Thread: ${post.rootId}',
  'Type: ${post.type.isEmpty ? '(regular message)' : post.type}',
  'Problem: ${post.decodeProblem ?? 'none'}',
].join('\n');

/// The decoded props and metadata of [post].
PostDetails detailsOf(PostItem post) =>
    detailsFor(post.id, post.propsJson, post.metadataJson);

/// Everyone who reacted to a post with one emoji.
@freezed
abstract class ReactionGroup with _$ReactionGroup {
  const factory ReactionGroup({
    required String emojiName,

    /// The people, first to react first.
    required List<PostPerson> people,

    /// The current user is among them.
    required bool mine,
  }) = _ReactionGroup;

  const ReactionGroup._();

  int get count => people.length;
}

/// Pure: [reactions] of one post grouped by emoji, in the order each emoji
/// was first used.
List<ReactionGroup> groupReactions(
  List<({String userId, String emojiName, DateTime? at})> reactions, {
  required String? myUserId,
  required PostPerson Function(String userId) personOf,
}) {
  final sorted = [...reactions]
    ..sort((a, b) {
      final x = a.at?.millisecondsSinceEpoch ?? 0;
      final y = b.at?.millisecondsSinceEpoch ?? 0;
      return x.compareTo(y);
    });
  final groups = <String, List<PostPerson>>{};
  final mine = <String>{};
  for (final r in sorted) {
    groups.putIfAbsent(r.emojiName, () => []).add(personOf(r.userId));
    if (r.userId == myUserId) mine.add(r.emojiName);
  }
  return [
    for (final MapEntry(:key, :value) in groups.entries)
      ReactionGroup(emojiName: key, people: value, mine: mine.contains(key)),
  ];
}

/// The stored part of a channel or thread that a conversation shows: the
/// newest [PostItem]s of the loaded range it is anchored in.
@freezed
abstract class ConversationWindow with _$ConversationWindow {
  const factory ConversationWindow({
    /// Newest first; replies only, for a thread.
    required List<PostItem> posts,

    /// Some history is stored, possibly none (an empty channel).
    required bool loaded,

    /// The oldest message of the conversation is in [posts].
    @Default(false) bool reachesStart,

    /// Older stored messages exist beyond [posts].
    @Default(false) bool moreStored,

    /// Newer messages are stored apart from these, after a gap.
    @Default(false) bool newerApart,

    /// The thread's first message.
    PostItem? root,
    @Default('') String channelName,

    /// `O`, `P`, `D` or `G`; direct and group messages are named after
    /// people, not by [channelName].
    @Default('') String channelType,

    /// The other person of a direct message.
    String? partnerId,
    @Default('') String teamId,
    int? memberCount,

    /// The channel is archived: it can be read but not written to.
    @Default(false) bool archived,
  }) = _ConversationWindow;
}

/// A row of a conversation list. [key] stays the same for the same row
/// across updates, so the list keeps its place and state.
@freezed
sealed class ListRow with _$ListRow {
  const factory ListRow.post(
    PostItem post, {

    /// Same author shortly after their previous message: no avatar or name.
    @Default(false) bool compact,

    /// Later membership messages of the same kind, told together with
    /// [post] in one line.
    @Default(<PostItem>[]) List<PostItem> combined,
  }) = MessageRow;

  const factory ListRow.day(DateTime day) = DaySeparator;

  /// Before the first message that arrived since the reader was last here.
  const factory ListRow.newMessages({required int count}) = NewMessagesLine;

  const ListRow._();

  Object get key => switch (this) {
    MessageRow(:final post) => post.key,
    DaySeparator(:final day) =>
      'day:${day.year}-${_two(day.month)}-${_two(day.day)}',
    NewMessagesLine() => newMessagesKey,
  };
}

const newMessagesKey = 'new-line';

String _two(int n) => n.toString().padLeft(2, '0');

const _groupWindow = Duration(minutes: 5);

/// The rows for [posts] (newest first), newest first: date separators,
/// grouping of consecutive messages, and the new-messages line before the
/// first message from someone else after [lastViewedAt]. System messages
/// such as joins don't start the line, and nor do messages created after
/// [unreadUntil], which arrived while the conversation was open.
List<ListRow> buildRows(
  List<PostItem> posts, {
  required DateTime? lastViewedAt,
  required String? myUserId,
  DateTime? unreadUntil,
}) {
  final rows = <ListRow>[];
  PostItem? previous;
  DateTime? previousDay;
  var lineAt = -1;
  for (final post in posts.reversed) {
    final local = post.createAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    var startsGroup = previous == null;
    if (day != previousDay) {
      rows.add(ListRow.day(day));
      previousDay = day;
      startsGroup = true;
    }
    if (lineAt < 0 &&
        lastViewedAt != null &&
        post.createAt.isAfter(lastViewedAt) &&
        (unreadUntil == null || !post.createAt.isAfter(unreadUntil)) &&
        post.userId != myUserId &&
        !post.isSystem &&
        !post.deleted) {
      lineAt = rows.length;
      rows.add(const ListRow.newMessages(count: 0));
      startsGroup = true;
    }
    final activity = Activity.of(post.type);
    if (activity != null && !startsGroup && rows.last is MessageRow) {
      final last = rows.last as MessageRow;
      final entry = activityEntry(activity, detailsOf(post).props);
      final lastEntry = activityEntry(activity, detailsOf(last.post).props);
      if (last.post.type == post.type &&
          !last.post.deleted &&
          !post.deleted &&
          entry.actor == lastEntry.actor) {
        rows[rows.length - 1] = last.copyWith(
          combined: [...last.combined, post],
        );
        previous = post;
        continue;
      }
    }
    final compact =
        !startsGroup &&
        previous != null &&
        previous.userId == post.userId &&
        !previous.isSystem &&
        !post.isSystem &&
        detailsOf(post).priority == null &&
        post.createAt.difference(previous.createAt) < _groupWindow;
    rows.add(ListRow.post(post, compact: compact));
    previous = post;
  }
  if (lineAt >= 0) {
    rows[lineAt] = ListRow.newMessages(
      count: rows.skip(lineAt).whereType<MessageRow>().length,
    );
  }
  return rows.reversed.toList();
}

/// Pure: [next] with every row that equals the row of the same key in
/// [previous] replaced by that instance, so unchanged rows stay identical
/// from one update to the next and their widgets aren't built again.
List<ListRow> reuseRows(List<ListRow> previous, List<ListRow> next) {
  if (previous.isEmpty) return next;
  final old = {for (final row in previous) row.key: row};
  return [
    for (final row in next)
      if (old[row.key] case final same? when same == row) same else row,
  ];
}

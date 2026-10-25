import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/system_message.dart';

part 'post_list.freezed.dart';

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

    /// Names of the people who replied, newest first, when known.
    @Default(<String>[]) List<String> participants,
    @Default('') String authorUsername,
    @Default(false) bool authorIsBot,
    int? authorPictureAt,

    /// The post's props and metadata as the server sent them; decoded when
    /// the row is drawn.
    String? propsJson,
    String? metadataJson,
    @Default(<ReactionGroup>[]) List<ReactionGroup> reactions,
  }) = _PostItem;

  const PostItem._();

  bool get isSystem => type.startsWith('system_') && !isEphemeral;
  bool get edited => editAt != null && !deleted;
  bool get isReply => rootId.isNotEmpty;
  bool get isEphemeral => type == 'system_ephemeral';
}

/// The decoded props and metadata of [post].
PostDetails detailsOf(PostItem post) =>
    detailsFor(post.id, post.propsJson, post.metadataJson);

/// Everyone who reacted to a post with one emoji.
@freezed
abstract class ReactionGroup with _$ReactionGroup {
  const factory ReactionGroup({
    required String emojiName,

    /// The people, first to react first.
    required List<String> names,

    /// The current user is among them.
    required bool mine,
  }) = _ReactionGroup;

  const ReactionGroup._();

  int get count => names.length;
}

/// Pure: [reactions] of one post grouped by emoji, in the order each emoji
/// was first used.
List<ReactionGroup> groupReactions(
  List<({String userId, String emojiName, DateTime? at})> reactions, {
  required String? myUserId,
  required String Function(String userId) nameOf,
}) {
  final sorted = [...reactions]
    ..sort((a, b) {
      final x = a.at?.millisecondsSinceEpoch ?? 0;
      final y = b.at?.millisecondsSinceEpoch ?? 0;
      return x.compareTo(y);
    });
  final groups = <String, List<String>>{};
  final mine = <String>{};
  for (final r in sorted) {
    groups.putIfAbsent(r.emojiName, () => []).add(nameOf(r.userId));
    if (r.userId == myUserId) mine.add(r.emojiName);
  }
  return [
    for (final MapEntry(:key, :value) in groups.entries)
      ReactionGroup(emojiName: key, names: value, mine: mine.contains(key)),
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
    @Default('') String teamId,
    int? memberCount,
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
/// first message from someone else after [lastViewedAt].
List<ListRow> buildRows(
  List<PostItem> posts, {
  required DateTime? lastViewedAt,
  required String? myUserId,
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
        post.userId != myUserId &&
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

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Today", "Yesterday", "Mon 20 Oct", or with the year when it isn't this
/// one. [day] and [now] are local times.
String dayLabel(DateTime day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(day.year, day.month, day.day);
  if (date == today) return 'Today';
  if (date == DateTime(today.year, today.month, today.day - 1)) {
    return 'Yesterday';
  }
  final label =
      '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
  return date.year == today.year ? label : '$label ${date.year}';
}

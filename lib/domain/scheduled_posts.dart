import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/people.dart';
import 'package:matterleast/domain/preview_text.dart';

/// A quick choice for when a message goes out.
typedef SchedulePreset = ({String label, DateTime at});

/// Pure: the quick choices offered on [clock]'s day, as the official app
/// offers them: tomorrow and Monday morning at 9:00, Monday alone at the
/// end of the week, "Next Monday" on a Monday. [nine] is how 9:00 reads.
List<SchedulePreset> schedulePresets(
  DialogClock clock, {
  required String nine,
}) {
  final today = clock.today;
  DateTime morning(int days) =>
      clock.fromWall(DateTime(today.year, today.month, today.day + days, 9));
  final tomorrow = (label: 'Tomorrow at $nine', at: morning(1));
  final daysToMonday = 8 - today.weekday;
  final monday = morning(daysToMonday);
  return switch (today.weekday) {
    DateTime.sunday => [tomorrow],
    DateTime.monday => [tomorrow, (label: 'Next Monday at $nine', at: monday)],
    DateTime.friday ||
    DateTime.saturday => [(label: 'Monday at $nine', at: monday)],
    _ => [tomorrow, (label: 'Monday at $nine', at: monday)],
  };
}

/// Pure: why the server could not send a scheduled message, from its
/// `error_code`; null when nothing went wrong.
String? scheduleProblem(String? code) => switch (code) {
  null || '' => null,
  'channel_archived' => 'The channel was archived',
  'channel_not_found' => 'The channel was removed',
  'user_missing' || 'user_deleted' => 'The recipient was deactivated',
  'no_channel_permission' => "You can't post in this channel any more",
  'no_channel_member' => "You're no longer in this channel",
  'thread_deleted' => 'The thread was deleted',
  'unable_to_send' => "The server couldn't send it",
  'invalid_post' => "The server couldn't accept it",
  'post_send_success_delete_failed' => 'It was sent; delete it here',
  _ => "It wasn't sent",
};

/// A scheduled message as the list reads it.
typedef ScheduledInput = ({
  String id,
  String channelId,
  String rootId,
  String message,
  int files,
  DateTime scheduledAt,
  String? errorCode,
});

/// One row of the scheduled list.
typedef ScheduledItem = ({
  String id,
  String channelId,
  String rootId,

  /// Where it goes: `#channel`, or the people of a direct message.
  String title,

  /// The partner of a direct message, for the avatar.
  String? userId,
  String preview,
  DateTime scheduledAt,

  /// Why it wasn't sent; null while it waits.
  String? problem,
});

/// Pure: the scheduled messages in [channels], failed ones first, then the
/// soonest. Messages to channels the user can't see are left out.
List<ScheduledItem> buildScheduledList(
  Iterable<ScheduledInput> posts, {
  required Map<String, ChannelInput> channels,
  required String myId,
  required Map<String, PersonInput> people,
  NameFormat nameFormat = NameFormat.username,
}) {
  final items = <ScheduledItem>[];
  for (final s in posts) {
    final c = channels[s.channelId];
    if (c == null) continue;
    final conversation = c.type == 'D' || c.type == 'G';
    final name = conversationName(
      c,
      myId: myId,
      people: people,
      nameFormat: nameFormat,
    );
    final text = previewText(s.message);
    items.add((
      id: s.id,
      channelId: s.channelId,
      rootId: s.rootId,
      title: conversation ? name.title : '#${c.displayName}',
      userId: name.userId,
      preview: text.isNotEmpty
          ? text
          : s.files == 1
          ? '1 file'
          : '${s.files} files',
      scheduledAt: s.scheduledAt,
      problem: scheduleProblem(s.errorCode),
    ));
  }
  items.sort((a, b) {
    final failed = (a.problem == null ? 1 : 0) - (b.problem == null ? 1 : 0);
    return failed != 0 ? failed : a.scheduledAt.compareTo(b.scheduledAt);
  });
  return items;
}

/// Pure: the line above the composer, such as "2 scheduled messages";
/// null for none.
String? scheduledCountLabel(int count) => switch (count) {
  0 => null,
  1 => '1 scheduled message',
  _ => '$count scheduled messages',
};

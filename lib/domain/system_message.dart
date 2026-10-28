import 'package:matterleast/api/json/post_extras.dart';

/// Current usernames by user id, for the people a system message names.
typedef Usernames = Map<String, String>;

/// A username as a markdown mention, so it renders tappable.
String _mention(String? username) =>
    username == null ? 'Someone' : '@$username';

/// The person's current username when their id is known, else the one the
/// server stored in the post.
String? _current(String? id, String? stored, Usernames names) =>
    (id == null ? null : names[id]) ?? stored;

/// Pure: the ids of the people a system message names.
Set<String> systemMessageUserIds(String userId, PostProps props) => {
  if (userId.isNotEmpty) userId,
  ?props.userId,
  ?props.addedUserId,
  ?props.removedUserId,
};

/// Pure: the markdown shown for a system message, in the wording of
/// Mattermost's apps. Headers and purposes stay markdown, as the official
/// apps render them. Types without their own wording use the server's
/// [message].
String systemMessageText(
  String type,
  PostProps props,
  String message, {
  String userId = '',
  Usernames names = const {},
}) {
  final who = _mention(_current(userId, props.username, names));
  String change(String what, String? from, String? to) {
    final old = from ?? '';
    final now = to ?? '';
    if (now.isEmpty && old.isNotEmpty) {
      return '$who removed the channel $what (was: $old)';
    }
    if (old.isEmpty) return '$who updated the channel $what to: $now';
    return '$who updated the channel $what from: $old to: $now';
  }

  return switch (type) {
    'system_header_change' => change(
      'header',
      props.oldHeader,
      props.newHeader,
    ),
    'system_purpose_change' => change(
      'purpose',
      props.oldPurpose,
      props.newPurpose,
    ),
    'system_displayname_change' => change(
      'display name',
      props.oldDisplayname,
      props.newDisplayname,
    ),
    'system_channel_deleted' => '$who archived the channel',
    'system_channel_restored' => '$who unarchived the channel',
    _ => message,
  };
}

/// How consecutive membership messages are told together.
enum Activity {
  joinedChannel('system_join_channel', 'joined the channel'),
  leftChannel('system_leave_channel', 'left the channel'),
  joinedTeam('system_join_team', 'joined the team'),
  leftTeam('system_leave_team', 'left the team'),
  addedToChannel('system_add_to_channel', 'added to the channel'),
  removedFromChannel('system_remove_from_channel', 'removed from the channel'),
  addedToTeam('system_add_to_team', 'added to the team'),
  removedFromTeam('system_remove_from_team', 'removed from the team');

  const Activity(this.type, this.verb);

  final String type;
  final String verb;

  static Activity? of(String type) =>
      values.where((a) => a.type == type).firstOrNull;

  /// Someone else did it to the people named.
  bool get byActor => switch (this) {
    addedToChannel ||
    removedFromChannel ||
    addedToTeam ||
    removedFromTeam => true,
    _ => false,
  };
}

/// Pure: whether a post of [type] is a membership message, which the
/// server leaves out of a channel's message count (`IsJoinLeaveMessage`).
bool isJoinLeave(String? type) =>
    type != null &&
    (Activity.of(type) != null ||
        type == 'system_join_leave' ||
        type == 'system_add_remove');

/// One membership message: who it is about and who did it.
typedef ActivityEntry = ({String? subject, String? actor});

/// Pure: the subject and actor of a membership message.
ActivityEntry activityEntry(
  Activity activity,
  PostProps props, {
  String userId = '',
  Usernames names = const {},
}) => activity.byActor
    ? (
        subject: _current(
          props.addedUserId ?? props.removedUserId,
          props.addedUsername ?? props.removedUsername,
          names,
        ),
        actor: _current(props.userId, props.username, names),
      )
    : (subject: _current(userId, props.username, names), actor: null);

/// Pure: one markdown sentence for consecutive membership messages of the
/// same kind ("@alice, @bob and @carol joined the channel.").
String activityText(Activity activity, List<ActivityEntry> entries) {
  final subjects = <String>[];
  for (final e in entries) {
    final subject = _mention(e.subject);
    if (!subjects.contains(subject)) subjects.add(subject);
  }
  final names = switch (subjects.length) {
    1 => subjects.single,
    _ =>
      '${subjects.take(subjects.length - 1).join(', ')} and ${subjects.last}',
  };
  final actor = entries.first.actor;
  return activity.byActor && actor != null
      ? '$names ${activity.verb} by ${_mention(actor)}.'
      : '$names ${activity.verb}.';
}

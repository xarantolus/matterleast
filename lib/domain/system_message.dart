import 'package:matterleast/api/json/post_extras.dart';

/// Pure: the line shown for a system message, in the wording of
/// Mattermost's apps. Types without their own wording use the server's
/// [message].
String systemMessageText(String type, PostProps props, String message) {
  final who = props.username ?? 'Someone';
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

/// One membership message: who it is about and who did it.
typedef ActivityEntry = ({String subject, String? actor});

/// Pure: the subject and actor of a membership message.
ActivityEntry activityEntry(Activity activity, PostProps props) =>
    activity.byActor
    ? (
        subject: props.addedUsername ?? props.removedUsername ?? 'Someone',
        actor: props.username,
      )
    : (subject: props.username ?? 'Someone', actor: null);

/// Pure: one sentence for consecutive membership messages of the same kind
/// ("alice, bob and carol joined the channel.").
String activityText(Activity activity, List<ActivityEntry> entries) {
  final subjects = <String>[];
  for (final e in entries) {
    if (!subjects.contains(e.subject)) subjects.add(e.subject);
  }
  final names = switch (subjects.length) {
    1 => subjects.single,
    _ =>
      '${subjects.take(subjects.length - 1).join(', ')} and ${subjects.last}',
  };
  final actor = entries.first.actor;
  return activity.byActor && actor != null
      ? '$names ${activity.verb} by $actor.'
      : '$names ${activity.verb}.';
}

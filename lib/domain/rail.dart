import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/channel_list.dart';

part 'rail.freezed.dart';
part 'rail.g.dart';

/// A team icon in the rail, with its badge.
@freezed
abstract class RailTeam with _$RailTeam {
  const factory RailTeam({
    required String id,
    required String displayName,
    required bool unread,
    required int mentions,
    @Default(false) bool urgent,

    /// The team's `last_team_icon_update`; null or 0 when it has no icon.
    int? iconUpdate,
  }) = _RailTeam;
}

/// What the rail points at: Home (null), a server whose teams are not known
/// yet, or one of its teams.
@freezed
abstract class RailTarget with _$RailTarget {
  const factory RailTarget({required String url, String? teamId}) = _RailTarget;

  factory RailTarget.fromJson(Map<String, Object?> json) =>
      _$RailTargetFromJson(json);
}

/// The team whose channels show for [target]: the one picked while the
/// server still has it, else the server's first. While the server's teams
/// are not stored yet the picked one stands.
String? shownTeam(RailTarget? target, List<RailTeam> teams) {
  if (target == null) return null;
  if (teams.isEmpty || teams.any((t) => t.id == target.teamId)) {
    return target.teamId ?? teams.firstOrNull?.id;
  }
  return teams.first.id;
}

/// What the rail shows for [selected]: Home when its server isn't signed in, else its shown team.
RailTarget? shownPlace(
  RailTarget? selected, {
  required Set<String>? signedIn,
  required List<RailTeam>? teams,
}) {
  if (selected == null) return null;
  if (signedIn != null && !signedIn.contains(selected.url)) return null;
  return RailTarget(
    url: selected.url,
    teamId: shownTeam(selected, teams ?? const []),
  );
}

/// Whether the rail moved to another server, team or Home; a team becoming known is no move.
bool placeChanged(RailTarget? before, RailTarget? after) {
  if (before == null || after == null) return before != after;
  return before.url != after.url ||
      (before.teamId != null &&
          after.teamId != null &&
          before.teamId != after.teamId);
}

/// Per team: mention and unread totals over its channels once they were
/// fetched, else the server's team counts from the entry sync. With
/// collapsed threads the team's followed threads count too, as in the
/// official app.
({bool unread, int mentions, bool urgent}) teamBadge({
  required bool channelsSynced,
  required int channelMentions,
  required bool anyChannelUnread,
  required int teamMentions,
  required int teamUnreadMessages,
  int threadMentions = 0,
  bool anyThreadUnread = false,
  int channelUrgent = 0,
  bool postPriority = false,
}) {
  final channels = channelsSynced
      ? (unread: anyChannelUnread, mentions: channelMentions)
      : (unread: teamUnreadMessages > 0, mentions: teamMentions);
  return (
    unread: channels.unread || anyThreadUnread,
    mentions: channels.mentions + threadMentions,
    urgent: urgentMentions(
      postPriority: postPriority,
      mentions: channels.mentions,
      urgent: channelsSynced ? channelUrgent : 0,
    ),
  );
}

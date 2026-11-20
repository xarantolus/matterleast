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

/// The selection once the server's teams changed from [before] to [after]:
/// a team that went away passes to the one that followed it, else the one
/// before it, and to Home (null) when no team is left. While no teams are
/// known yet nothing changes.
RailTarget? settledSelection(
  RailTarget? selected, {
  required List<RailTeam>? before,
  required List<RailTeam> after,
}) {
  final gone = selected?.teamId;
  if (selected == null || gone == null) return selected;
  final known = before ?? const <RailTeam>[];
  if (after.isEmpty) return known.isEmpty ? selected : null;
  if (after.any((t) => t.id == gone)) return selected;
  final at = known.indexWhere((t) => t.id == gone);
  final kept = {for (final t in after) t.id};
  final following = at < 0 ? const <RailTeam>[] : known.sublist(at + 1);
  final preceding = at < 0 ? const <RailTeam>[] : known.sublist(0, at);
  final next =
      following.where((t) => kept.contains(t.id)).firstOrNull ??
      preceding.where((t) => kept.contains(t.id)).lastOrNull ??
      after.first;
  return RailTarget(url: selected.url, teamId: next.id);
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

/// The numbers a server reports per team in its unread counts; with
/// collapsed threads the root-only message and mention counts, plus its
/// followed threads.
typedef TeamCounts = ({
  int messages,
  int mentions,
  int threads,
  int threadMentions,
});

const noTeamCounts = (messages: 0, mentions: 0, threads: 0, threadMentions: 0);

/// A team's channel counts as the server adds them up: unread messages of
/// channels that aren't muted or archived, mentions of every live channel,
/// muted ones too.
({int messages, int mentions}) channelCounts(
  Iterable<ChannelInput> channels, {
  required bool crt,
}) {
  var messages = 0;
  var mentions = 0;
  for (final c in channels) {
    if (c.archived) continue;
    mentions += crt ? c.mentionCountRoot : c.mentionCount;
    if (!c.muted) messages += unreadMessages(c, crt);
  }
  return (messages: messages, mentions: mentions);
}

/// The teams whose channels, and whose followed threads, must be fetched
/// because the server's counts differ from the [local] ones derived from
/// what is stored. A team without fetched channels ([unsynced]) always
/// differs.
({Set<String> channels, Set<String> threads}) staleTeams({
  required Map<String, TeamCounts> server,
  required Map<String, TeamCounts> local,
  Set<String> unsynced = const {},
}) {
  final channels = <String>{};
  final threads = <String>{};
  for (final MapEntry(key: id, value: s) in server.entries) {
    final l = local[id] ?? noTeamCounts;
    if (unsynced.contains(id) ||
        s.messages != l.messages ||
        s.mentions != l.mentions) {
      channels.add(id);
    }
    if (s.threads != l.threads || s.threadMentions != l.threadMentions) {
      threads.add(id);
    }
  }
  return (channels: channels, threads: threads);
}

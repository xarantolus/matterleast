import 'package:freezed_annotation/freezed_annotation.dart';

part 'rail.freezed.dart';

/// A team icon in the rail, with its badge.
@freezed
abstract class RailTeam with _$RailTeam {
  const factory RailTeam({
    required String id,
    required String displayName,
    required bool unread,
    required int mentions,
  }) = _RailTeam;
}

/// What the rail points at: Home (null), a server whose teams are not known
/// yet, or one of its teams.
@freezed
abstract class RailTarget with _$RailTarget {
  const factory RailTarget({required String url, String? teamId}) = _RailTarget;
}

/// Per team: mention and unread totals over its channels once they were
/// fetched, else the server's team counts from the entry sync.
({bool unread, int mentions}) teamBadge({
  required bool channelsSynced,
  required int channelMentions,
  required bool anyChannelUnread,
  required int teamMentions,
  required int teamUnreadMessages,
}) => channelsSynced
    ? (unread: anyChannelUnread, mentions: channelMentions)
    : (unread: teamUnreadMessages > 0, mentions: teamMentions);

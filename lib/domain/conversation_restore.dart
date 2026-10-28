import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';

part 'conversation_restore.freezed.dart';
part 'conversation_restore.g.dart';

/// The conversation that was open on top when the app last ran: a channel,
/// or the thread of [rootId] in it. [title] is the channel's name.
@freezed
abstract class SavedConversation with _$SavedConversation {
  const factory SavedConversation({
    required String url,
    required String channelId,
    required String title,
    String? teamId,
    String? rootId,
  }) = _SavedConversation;

  factory SavedConversation.fromJson(Map<String, Object?> json) =>
      _$SavedConversationFromJson(json);
}

/// What each place of the rail (a team, a server whose teams aren't known
/// yet, Home) had open last, so switching back reopens it and a launch
/// reopens the one of the place it shows, and what it closed last, which a
/// swipe brings back.
@freezed
abstract class OpenConversations with _$OpenConversations {
  const factory OpenConversations({
    @Default(<String, SavedConversation>{}) Map<String, SavedConversation> open,
    @Default(<String, SavedConversation>{})
    Map<String, SavedConversation> closed,
  }) = _OpenConversations;

  const OpenConversations._();

  factory OpenConversations.fromJson(Map<String, Object?> json) =>
      _$OpenConversationsFromJson(json);

  static const none = OpenConversations();

  /// What is open in [place]; null while its list shows.
  SavedConversation? at(RailTarget? place) => open[_key(place)];

  /// What [place] closed last.
  SavedConversation? closedAt(RailTarget? place) => closed[_key(place)];

  /// [now] shows in [place]; null when its list shows.
  OpenConversations withOpen(RailTarget? place, SavedConversation? now) =>
      copyWith(open: _with(open, place, now));

  /// [place] closed [conversation].
  OpenConversations withClosed(
    RailTarget? place,
    SavedConversation conversation,
  ) => copyWith(closed: _with(closed, place, conversation));

  static Map<String, SavedConversation> _with(
    Map<String, SavedConversation> map,
    RailTarget? place,
    SavedConversation? value,
  ) => {
    for (final e in map.entries)
      if (e.key != _key(place)) e.key: e.value,
    _key(place): ?value,
  };

  static String _key(RailTarget? place) =>
      place == null ? '' : '${place.url} ${place.teamId ?? ''}';
}

/// Whether [conversation] is one of [place]'s: on its server, and in its
/// team unless either names none (a direct message, a server whose teams
/// aren't known yet). Home has none of its own: opening a conversation
/// moves the rail to its team.
bool belongsTo(SavedConversation conversation, RailTarget? place) =>
    place != null &&
    conversation.url == place.url &&
    (conversation.teamId == null ||
        place.teamId == null ||
        conversation.teamId == place.teamId);

/// What to remember of the open conversations: the one on top, or nothing
/// when the channel list shows.
SavedConversation? conversationToSave(Panes open) {
  final top = open.thread ?? open.channel;
  return switch (top) {
    ThreadTarget() => SavedConversation(
      url: top.url,
      channelId: top.channelId,
      title: top.channelName,
      teamId: top.teamId,
      rootId: top.rootId,
    ),
    ChannelTarget() => SavedConversation(
      url: top.url,
      channelId: top.channelId,
      title: top.title,
      teamId: top.teamId,
    ),
    null => null,
  };
}

/// The conversations to open at launch, bottom first (a thread comes with
/// its channel beneath it), or none: when something else launched the app
/// (a notification, a link, a share), when the server is no longer signed
/// in, or when the channel is gone, left or archived. [channels] are the
/// server's joined channels by id, with their current names.
List<ConversationTarget> conversationsToRestore({
  required SavedConversation? saved,
  required bool launchedByIntent,
  required Set<String> signedInUrls,
  required Map<String, SwitchItem> channels,
}) {
  if (saved == null || launchedByIntent) return const [];
  if (!signedInUrls.contains(saved.url)) return const [];
  final channel = channels[saved.channelId];
  if (channel == null ||
      !channel.joined ||
      channel.kind == SwitchKind.archived) {
    return const [];
  }
  final teamId = channel.teamId ?? saved.teamId;
  final root = saved.rootId;
  return [
    ConversationTarget.channel(
      url: saved.url,
      channelId: saved.channelId,
      title: channel.title,
      teamId: teamId,
    ),
    if (root != null)
      ConversationTarget.thread(
        url: saved.url,
        channelId: saved.channelId,
        rootId: root,
        channelName: channel.title,
        teamId: teamId,
      ),
  ];
}

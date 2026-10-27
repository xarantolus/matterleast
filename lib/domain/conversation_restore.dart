import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';

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

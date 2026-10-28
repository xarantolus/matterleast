import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/screens/open_channel.dart';

/// Opens what a preview row points at: the conversation at the message,
/// or its thread. With [besideContent] a thread opens beside the content
/// view the row is in, where the window has a pane for it.
Future<void> openInboxItem(
  BuildContext context,
  InboxItem item, {
  bool besideContent = false,
}) {
  final rootId = item.rootId;
  final thread =
      rootId != null && (item.kind == InboxKind.thread || item.inThread);
  return openConversation(
    Navigator.of(context),
    url: item.serverUrl,
    channelId: item.channelId,
    title: (item.place ?? item.title).replaceFirst(RegExp('^#'), ''),
    teamId: item.teamId,
    rootId: thread ? rootId : null,
    highlightPostId: item.postId,
    besideContent: besideContent,
  );
}

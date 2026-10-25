import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/empty_state.dart';

/// A conversation. Messages come with the channel view; for now it names
/// the channel, and where it would open.
class ChannelScreen extends StatelessWidget {
  const ChannelScreen({
    required this.title,
    required this.channelId,
    this.highlightPostId,
    this.rootId,
    super.key,
  });

  final String title;
  final String channelId;

  /// The message to jump to and highlight.
  final String? highlightPostId;

  /// Opens the thread of this root post instead of the channel.
  final String? rootId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(rootId == null ? title : 'Thread')),
    body: EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Messages arrive in the next milestone',
      body: [
        if (rootId != null)
          'Thread in $title.'
        else
          'This channel is marked as read.',
        if (highlightPostId != null) 'It will open at the message you picked.',
      ].join(' '),
    ),
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// A channel's messages, opened at the new-messages line, a message asked
/// for, or where the reader left off.
class ChannelScreen extends ConsumerWidget {
  const ChannelScreen({
    required this.url,
    required this.channelId,
    required this.title,
    this.highlightPostId,
    super.key,
  });

  final String url;
  final String channelId;
  final String title;

  /// The message to show centred and highlighted.
  final String? highlightPostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = conversationProvider(
      url,
      channelId,
      highlightPostId: highlightPostId,
    );
    final state = ref.watch(conversation);
    final window = state.window;
    final name = switch (window) {
      ConversationWindow(:final channelName, :final channelType)
          when channelName.isNotEmpty &&
              channelType != 'D' &&
              channelType != 'G' =>
        channelName,
      _ => title,
    };
    return Scaffold(
      appBar: AppBar(
        title: ConversationTitle(
          title: name,
          subtitle: conversationSubtitle(state),
        ),
        bottom: ProgressSlot(
          active: state.refreshing && state.window?.posts.isNotEmpty == true,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ConversationView(
          url: url,
          conversation: conversation,
          startText: 'This is the start of $name.',
          onOpenThread: (post) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ThreadScreen(
                url: url,
                channelId: channelId,
                rootId: post.id,
                channelName: name,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A title with a quiet line under it.
class ConversationTitle extends StatelessWidget {
  const ConversationTitle({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle case final subtitle?)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
      ],
    );
  }
}

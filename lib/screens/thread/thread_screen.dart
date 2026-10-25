import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// A thread: its first message, then the replies.
class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.channelName,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String channelName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = conversationProvider(url, channelId, rootId: rootId);
    final state = ref.watch(conversation);
    final offline = state.refreshFailure != null && !state.refreshing;
    return Scaffold(
      appBar: AppBar(
        title: ConversationTitle(
          title: 'Thread',
          subtitle: [
            if (state.window?.channelName case final name? when name.isNotEmpty)
              name
            else
              channelName,
            if (offline && state.window?.root != null) 'Offline',
          ].join(' · '),
        ),
        bottom: ProgressSlot(
          active: state.refreshing && state.window?.root != null,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ConversationView(
          url: url,
          conversation: conversation,
          startText: null,
        ),
      ),
    );
  }
}

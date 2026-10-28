import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_scaffold.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/thread/thread_providers.dart';
import 'package:matterleast/ui/clickable.dart';

/// A thread: its first message, then the replies.
class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.channelName,
    this.highlightPostId,
    this.focusComposer = false,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String channelName;

  /// The reply to show centred and highlighted.
  final String? highlightPostId;

  /// The composer takes the keyboard when it shows, as after Reply.
  final bool focusComposer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = conversationProvider(
      url,
      channelId,
      rootId: rootId,
      highlightPostId: highlightPostId,
    );
    final state = ref.watch(conversation);
    final following = ref.watch(threadFollowingProvider(url, rootId)).value;
    return ConversationScaffold(
      url: url,
      channelId: channelId,
      rootId: rootId,
      conversation: conversation,
      title: Semantics(
        button: true,
        hint: 'Opens the channel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openChannel(context, ref, state),
          child: Clickable(
            child: ConversationTitle(
              title: 'Thread',
              subtitle: threadSubtitle(state, channelName: channelName),
              opensSubtitle: true,
            ),
          ),
        ),
      ),
      actions: [
        if (following != null)
          _FollowButton(
            following: following,
            onPressed: () => _setFollowing(context, ref, !following),
          ),
      ],
      composerHint: 'Reply…',
      dropTarget: 'this thread',
      focusComposer: focusComposer,
    );
  }

  void _openChannel(
    BuildContext context,
    WidgetRef ref,
    ConversationState state,
  ) {
    unawaited(
      openConversation(
        Navigator.of(context),
        url: url,
        channelId: channelId,
        title: channelName,
        teamId: state.window?.teamId,
      ),
    );
    ref.read(openPanesProvider.notifier).closeThread();
  }

  Future<void> _setFollowing(
    BuildContext context,
    WidgetRef ref,
    bool following,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(
            conversationProvider(
              url,
              channelId,
              rootId: rootId,
              highlightPostId: highlightPostId,
            ).notifier,
          )
          .setFollowing(following: following);
    } on ApiError catch (e) {
      final what = following
          ? "Couldn't follow the thread."
          : "Couldn't stop following the thread.";
      messenger.showSnackBar(
        SnackBar(
          content: Text('$what ${requestProblemText(e, Uri.parse(url).host)}'),
        ),
      );
    }
  }
}

/// Follow or Following, as a quiet outlined button in the app bar.
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onPressed});

  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: following
          ? FilledButton.tonal(
              onPressed: onPressed,
              child: const Text('Following'),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
              ),
              onPressed: onPressed,
              child: const Text('Follow'),
            ),
    );
  }
}

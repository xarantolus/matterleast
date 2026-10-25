import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/typing.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/channel/dialog_screen.dart';
import 'package:matterleast/screens/thread/thread_providers.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// A thread: its first message, then the replies.
class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.channelName,
    this.highlightPostId,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String channelName;

  /// The reply to show centred and highlighted.
  final String? highlightPostId;

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
    final offline = state.refreshFailure != null && !state.refreshing;
    final typing = ref.watch(typingNamesProvider(url, channelId, rootId)).value;
    listenForRejectedPosts(context, ref, url, channelId);
    listenForDialogs(
      context,
      ref,
      url: url,
      channelId: channelId,
      teamId: state.window?.teamId ?? '',
    );
    final window = state.window;
    return Scaffold(
      appBar: AppBar(
        title: ConversationTitle(
          title: 'Thread',
          subtitle:
              typingText(typing ?? const []) ??
              [
                if (window?.channelName case final name? when name.isNotEmpty)
                  name
                else
                  channelName,
                if (offline && window?.root != null) 'Offline',
              ].join(' · '),
        ),
        actions: [
          if (following != null)
            _FollowButton(
              following: following,
              onPressed: () => _setFollowing(context, ref, !following),
            ),
        ],
        bottom: ProgressSlot(
          active: state.refreshing && state.window?.root != null,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: window == null,
        child: Column(
          children: [
            Expanded(
              child: ConversationView(
                url: url,
                conversation: conversation,
                composer: window == null || window.archived
                    ? null
                    : composerDraftProvider(url, channelId, rootId),
                startText: null,
              ),
            ),
            if (window != null)
              Composer(
                url: url,
                channelId: channelId,
                rootId: rootId,
                teamId: window.teamId,
                hint: 'Reply…',
                archived: window.archived,
              ),
          ],
        ),
      ),
    );
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
    } on ApiError {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            following
                ? "Couldn't follow the thread. Check the connection and try again."
                : "Couldn't stop following the thread. Check the connection "
                      'and try again.',
          ),
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
    final color = Theme.of(context).appBarTheme.foregroundColor;
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
                side: BorderSide(color: color ?? Colors.white),
              ),
              onPressed: onPressed,
              child: const Text('Follow'),
            ),
    );
  }
}

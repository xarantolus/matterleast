import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/typing.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/channel/dialog_screen.dart';
import 'package:matterleast/screens/channel_info/channel_info_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
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
    final partnerId = window?.partnerId;
    final partner = partnerId == null
        ? null
        : ref.watch(userProfileProvider(url, partnerId)).value;
    final typing = ref.watch(typingNamesProvider(url, channelId, '')).value;
    listenForRejectedPosts(context, ref, url, channelId);
    listenForDialogs(
      context,
      ref,
      url: url,
      channelId: channelId,
      teamId: window?.teamId ?? '',
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChannelInfoScreen(url: url, channelId: channelId),
            ),
          ),
          child: switch (typingText(typing ?? const [])) {
            final typing? => ConversationTitle(title: name, subtitle: typing),
            null => ConversationTitle(
              title: name,
              subtitle: conversationSubtitle(state, partner: partner),
              subtitleEmoji: conversationSubtitleEmoji(state, partner: partner),
              url: url,
            ),
          },
        ),
        bottom: ProgressSlot(
          active: state.refreshing && state.window?.posts.isNotEmpty == true,
        ),
      ),
      body: ConversationPane(
        child: SafeArea(
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
                      : composerDraftProvider(url, channelId, ''),
                  startText: 'This is the start of $name.',
                  onOpenThread: (post) => openConversation(
                    Navigator.of(context),
                    url: url,
                    channelId: channelId,
                    title: name,
                    teamId: window?.teamId,
                    rootId: post.id,
                  ),
                ),
              ),
              if (window != null)
                Composer(
                  url: url,
                  channelId: channelId,
                  teamId: window.teamId,
                  hint: 'Write to $name',
                  archived: window.archived,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A title with a quiet line under it.
class ConversationTitle extends StatelessWidget {
  const ConversationTitle({
    required this.title,
    this.subtitle,
    this.subtitleEmoji,
    this.url,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// An emoji before the subtitle, from the server at [url].
  final String? subtitleEmoji;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor);
    final emoji = subtitleEmoji;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle case final subtitle?)
          Text.rich(
            TextSpan(
              children: [
                if (emoji != null) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: EmojiGlyph(
                      name: emoji,
                      size: (style?.fontSize ?? 12) * 1.25,
                      serverUrl: url,
                    ),
                  ),
                  const TextSpan(text: ' '),
                ],
                TextSpan(text: subtitle),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
      ],
    );
  }
}

/// Tells the user when the server refused one of their posts in
/// [channelId] for good.
void listenForRejectedPosts(
  BuildContext context,
  WidgetRef ref,
  String url,
  String channelId,
) => ref.listen(rejectedPostsProvider(url), (_, next) {
  final rejected = next.value;
  if (rejected == null || rejected.channelId != channelId) return;
  final reason = rejected.message;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        reason == null || reason.isEmpty
            ? "The server didn't accept your message."
            : "The server didn't accept your message: $reason",
      ),
    ),
  );
});

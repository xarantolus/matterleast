import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/bookmark_bar.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_scaffold.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel_info/channel_info_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/you/profile_providers.dart';

/// A channel's messages, opened at the new-messages line, a message asked
/// for, or where the reader left off.
class ChannelScreen extends ConsumerWidget {
  const ChannelScreen({
    required this.url,
    required this.channelId,
    required this.title,
    this.highlightPostId,
    this.focusComposer = false,
    super.key,
  });

  final String url;
  final String channelId;
  final String title;

  /// The message to show centred and highlighted.
  final String? highlightPostId;

  /// The composer takes the keyboard when it shows.
  final bool focusComposer;

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
        : ref
              .watch(userProfileProvider(url, partnerId))
              .value
              ?.copyWith(
                customStatus: ref.watch(
                  activeCustomStatusProvider(url, partnerId),
                ),
              );
    final presenceKnown =
        partnerId != null && ref.watch(presenceKnownProvider(url, partnerId));
    void openInfo() => openPage(
      Navigator.of(context),
      ChannelInfoScreen(
        url: url,
        channelId: channelId,
        unreadSince: unreadSince(state.rows, state.lastViewedAt),
      ),
      popout: true,
    );
    return ConversationScaffold(
      url: url,
      channelId: channelId,
      conversation: conversation,
      title: Semantics(
        button: true,
        hint: 'Shows details',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: openInfo,
          child: ConversationTitle(
            title: name,
            subtitle: conversationSubtitle(
              state,
              partner: partner,
              presenceKnown: presenceKnown,
            ),
            statusOf: conversationSubtitleEmoji(state, partner: partner) == null
                ? null
                : partnerId,
            url: url,
            opensDetails: true,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Details',
          icon: const Icon(Icons.info_outline),
          onPressed: openInfo,
        ),
      ],
      header: BookmarkBar(url: url, channelId: channelId),
      composerHint: 'Write to $name',
      dropTarget: name,
      focusComposer: focusComposer,
      startText: 'This is the start of $name.',
      onOpenThread: (post, {reply = false}) => openConversation(
        Navigator.of(context),
        url: url,
        channelId: channelId,
        title: name,
        teamId: window?.teamId,
        rootId: post.isReply ? post.rootId : post.id,
        highlightPostId: post.isReply ? post.id : null,
        focusComposer: reply,
      ),
    );
  }
}

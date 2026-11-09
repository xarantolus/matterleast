import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/bookmark_bar.dart';
import 'package:matterleast/screens/channel/channel_banner_strip.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_scaffold.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/header_strip.dart';
import 'package:matterleast/screens/channel_info/channel_info_screen.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/status/status_providers.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/call_actions_ui.dart';
import 'package:matterleast/ui/call_join_banner.dart';
import 'package:matterleast/ui/clickable.dart';

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
    // The title comes from the channel itself, so every way of opening it
    // shows the same one; [title] only covers the moment before it is known.
    final name =
        ref.watch(channelInfoProvider(url, channelId)).value?.title ?? title;
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
    final liveNotice = ref.watch(serverLiveNoticeProvider(url));
    final presenceKnown =
        partnerId != null && ref.watch(presenceKnownProvider(url, partnerId));
    final channelType = window?.channelType ?? '';
    final callAction = channelType.isEmpty
        ? CallAction.none
        : ref.watch(callActionInProvider(url, channelId, channelType));
    final calls = ref.watch(callControllerProvider);
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
          child: Clickable(
            child: ConversationTitle(
              title: name,
              subtitle: conversationSubtitle(
                state,
                partner: partner,
                presenceKnown: presenceKnown,
                liveNotice: liveNotice,
              ),
              statusOf:
                  conversationSubtitleEmoji(
                        state,
                        partner: partner,
                        liveNotice: liveNotice,
                      ) ==
                      null
                  ? null
                  : partnerId,
              url: url,
              opensDetails: true,
            ),
          ),
        ),
      ),
      actions: [
        if (callAction != CallAction.none)
          IconButton(
            tooltip: callAction == CallAction.join ? 'Join call' : 'Start call',
            icon: const Icon(Icons.call_outlined),
            onPressed: () => joinCall(
              context,
              calls,
              url: url,
              channelId: channelId,
              start: callAction != CallAction.join,
            ),
          ),
        IconButton(
          tooltip: 'Details',
          icon: const Icon(Icons.info_outline),
          onPressed: openInfo,
        ),
      ],
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChannelBannerStrip(url: url, channelId: channelId),
          HeaderStrip(url: url, channelId: channelId),
          CallJoinBanner(
            url: url,
            channelId: channelId,
            channelType: channelType,
          ),
          BookmarkBar(url: url, channelId: channelId),
        ],
      ),
      composerHint: 'Write to $name',
      dropTarget: name,
      focusComposer: focusComposerOnOpen(
        asked: focusComposer,
        desktop: isDesktop,
        channelType: window?.channelType,
      ),
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

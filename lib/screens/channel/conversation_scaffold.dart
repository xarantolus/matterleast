import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/composer_desktop.dart';
import 'package:matterleast/screens/channel/composer_keys.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_keys.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/channel/dialog_screen.dart';
import 'package:matterleast/screens/channel/typing_line.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/custom_status_emoji.dart';
import 'package:matterleast/ui/focus_region.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// What a channel and a thread have in common: the app bar with its
/// progress slot and Retry, the messages, the typing line and the
/// composer.
class ConversationScaffold extends ConsumerWidget {
  const ConversationScaffold({
    required this.url,
    required this.channelId,
    required this.conversation,
    required this.title,
    required this.composerHint,
    this.rootId = '',
    this.actions = const [],
    this.startText,
    this.onOpenThread,
    this.header,
    this.focusComposer = false,
    this.dropTarget = 'this conversation',
    super.key,
  });

  final String url;
  final String channelId;

  /// The thread's first message; empty for a channel.
  final String rootId;
  final ConversationProvider conversation;
  final Widget title;
  final List<Widget> actions;
  final String composerHint;
  final String? startText;
  final OpenThread? onOpenThread;

  /// Shown between the app bar and the messages, such as bookmarks.
  final Widget? header;

  /// The composer takes the keyboard when it shows.
  final bool focusComposer;

  /// What dropped files are attached to, for the drop veil.
  final String dropTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversation);
    final window = state.window;
    listenForRejectedPosts(context, ref, url, channelId);
    listenForDialogs(
      context,
      ref,
      url: url,
      channelId: channelId,
      teamId: window?.teamId ?? '',
    );
    final info = ref.watch(channelInfoProvider(url, channelId)).value;
    return Actions(
      actions: {
        SearchChannelIntent: EnabledAction<SearchChannelIntent>(
          enabled: () => info != null,
          onInvoke: (_) => unawaited(_searchHere(context, info!)),
        ),
      },
      child: ContentPage(
        focusRegion: false,
        title: title,
        actions: [
          if (staleFailure(state) != null)
            IconButton(
              tooltip: 'Retry',
              icon: const Icon(Icons.refresh),
              onPressed: ref.read(conversation.notifier).retry,
            ),
          ...actions,
        ],
        progress:
            (state.refreshing || ref.watch(serverCatchingUpProvider(url))) &&
            showsMessages(state),
        progressDelay: ProgressSlot.settleDelay,
        body: ConversationKeys(
          conversation: conversation,
          isThread: rootId.isNotEmpty,
          builder: (composerFocus, list) => ConversationDropTarget(
            url: url,
            channelId: channelId,
            rootId: rootId,
            target: dropTarget,
            child: _Readable(
              child: SafeArea(
                top: false,
                bottom: window == null,
                child: Column(
                  children: [
                    ?header,
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FocusRegion(
                              entry: RegionEntry.self,
                              child: ConversationView(
                                url: url,
                                conversation: conversation,
                                composer: window == null || window.archived
                                    ? null
                                    : composerDraftProvider(
                                        url,
                                        channelId,
                                        rootId,
                                      ),
                                startText: startText,
                                list: list,
                                onOpenThread: onOpenThread,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: TypingLine(
                              url: url,
                              channelId: channelId,
                              rootId: rootId,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (window != null)
                      FocusRegion(
                        entry: RegionEntry.textField,
                        child: Composer(
                          url: url,
                          channelId: channelId,
                          rootId: rootId,
                          teamId: window.teamId,
                          hint: composerHint,
                          archived: window.archived,
                          autofocus: focusComposer,
                          focusNode: composerFocus,
                          lastOwnPost: () {
                            final now = ref.read(conversation);
                            return lastOwnPost(now.rows, now.myUserId);
                          },
                          ownTexts: () {
                            final now = ref.read(conversation);
                            return [
                              for (final post in ownPosts(
                                now.rows,
                                now.myUserId,
                              ))
                                post.message,
                            ];
                          },
                          onReplyToNewest: onOpenThread == null
                              ? null
                              : () {
                                  final post = newestReplyable(
                                    ref.read(conversation).rows,
                                  );
                                  if (post != null) {
                                    onOpenThread!(post, reply: true);
                                  }
                                },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _searchHere(BuildContext context, ChannelInfo info) => openPage(
    Navigator.of(context),
    SearchResultsScreen(
      url: url,
      teamId: info.teamId,
      query: '',
      scope: SearchScope(
        teamId: info.teamId,
        channelId: info.id,
        channelName: info.name,
        channelLabel: info.conversation ? info.title : '#${info.title}',
      ),
    ),
  );
}

/// A title with a quiet line under it.
class ConversationTitle extends StatelessWidget {
  const ConversationTitle({
    required this.title,
    this.subtitle,
    this.statusOf,
    this.url,
    this.opensDetails = false,
    this.opensSubtitle = false,
    super.key,
  });

  final String title;

  /// Shows a small chevron after the title, which opens the details.
  final bool opensDetails;

  /// Shows a small chevron after the subtitle, which opens what it names.
  final bool opensSubtitle;
  final String? subtitle;

  /// The person whose custom status emoji goes before the subtitle, on
  /// the server at [url].
  final String? statusOf;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor);
    final person = statusOf;
    final server = url;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (opensDetails)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          )
        else
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle case final subtitle?)
          Text.rich(
            TextSpan(
              children: [
                if (person != null && server != null)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: CustomStatusEmoji(
                      serverUrl: server,
                      userId: person,
                      size: (style?.fontSize ?? 12) * 1.25,
                      padding: const EdgeInsetsDirectional.only(end: 4),
                    ),
                  ),
                TextSpan(text: subtitle),
                if (opensSubtitle)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.chevron_right,
                      size: (style?.fontSize ?? 12) * 1.4,
                      color: style?.color,
                    ),
                  ),
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

/// A readable column width on a tablet; the whole width on desktop.
class _Readable extends StatelessWidget {
  const _Readable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? double.infinity : readableWidth,
      ),
      child: child,
    ),
  );
}

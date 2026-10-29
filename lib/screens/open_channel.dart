import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/conversation_stack.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/open_history.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/ui/conversation_route.dart';

/// Opens a conversation the user is in, the one way every screen does it:
/// its server and team in the rail, then the channel, or the thread of
/// [rootId], at [highlightPostId] when given. Opening a channel (not a
/// thread) remembers it as the team's last one and marks it viewed. With
/// [instant] it is there at once instead of sliding in. On a narrow screen
/// it goes back to the conversation when it is already open, and takes the
/// place of other conversations rather than piling up on them
/// ([stackStepFor]); on a wide one it opens in the panes. Opened
/// [fromOutside] the app, Back leads to the list unless it is a thread of
/// the open channel. With [focusComposer] its composer takes the keyboard.
/// With [besideContent] a thread opens in the thread pane of a large window
/// and leaves the content view in the main pane in place.
/// Opens that aren't the user's own ([recordHistory] false) stay out of the
/// Back and Forward history, which notes where the reader was first. Completes once the conversation closes.
Future<void> openConversation(
  NavigatorState from, {
  required String url,
  required String channelId,
  required String title,
  String? teamId,
  String? rootId,
  String? highlightPostId,
  bool instant = false,
  bool focusComposer = false,
  bool fromOutside = false,
  bool besideContent = false,
  bool recordHistory = true,
}) async {
  if (!from.mounted) return;
  final navigator = outsidePopout(from);
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  if (recordHistory) settleLocation(container);
  final picked = container.read(railSelectionProvider);
  final team = (teamId?.isNotEmpty ?? false)
      ? teamId
      : (picked?.url == url ? picked?.teamId : null);
  container
      .read(railSelectionProvider.notifier)
      .select(RailTarget(url: url, teamId: team));
  if (recordHistory) {
    container
        .read(openHistoryProvider)
        .push(
          Location(
            place: RailTarget(url: url, teamId: team),
            conversation: SavedConversation(
              url: url,
              channelId: channelId,
              title: title,
              teamId: team,
              rootId: rootId,
            ),
            highlightPostId: highlightPostId,
          ),
        );
  }
  if (rootId == null) {
    final actions = container.read(channelActionsProvider(url).future);
    unawaited(actions.then((a) => a.open(channelId, teamId: team)));
  }
  final target = rootId != null
      ? ConversationTarget.thread(
          url: url,
          channelId: channelId,
          rootId: rootId,
          channelName: title,
          teamId: team,
          highlightPostId: highlightPostId,
          focusComposer: focusComposer,
        )
      : ConversationTarget.channel(
          url: url,
          channelId: channelId,
          title: title,
          teamId: team,
          highlightPostId: highlightPostId,
          focusComposer: focusComposer,
        );
  final windowClass = windowClassOf(MediaQuery.sizeOf(navigator.context).width);
  if (windowClass.showsPanes) {
    // Whatever covers the panes, and the content views over the
    // conversation, give way to it.
    if (!(besideContent &&
        target is ThreadTarget &&
        windowClass.showsThreadPane)) {
      for (final routes in [
        container.read(paneRoutesProvider),
        container.read(conversationRoutesProvider),
      ]) {
        routes.navigator?.popUntil((route) => route.isFirst);
      }
      navigator.popUntil((route) => route.isFirst);
    }
    container.read(openPanesProvider.notifier).open(target);
    return;
  }
  final open = [
    for (final route in container.read(conversationRoutesProvider).live)
      if (route.navigator == navigator) route,
  ];
  final step = stackStepFor(
    [for (final r in open) r.target],
    target,
    fromOutside: fromOutside,
  );
  final route = conversationRoute(
    target,
    instant: instant || step is ReturnToStep,
  );
  switch (step) {
    case PushStep():
      unawaited(navigator.push(route));
    case ReturnToStep(:final index):
      navigator.popUntil((r) => r == open[index]);
      if (target.highlightPostId == null && !focusComposer) {
        await open[index].popped;
        return;
      }
      // In place, as a pane would, so it opens at the message.
      navigator.replace(oldRoute: open[index], newRoute: route);
    case PushOverStep(:final index):
      navigator.popUntil((r) => r == open[index]);
      unawaited(navigator.push(route));
    case ReplaceStep(:final index):
      navigator.popUntil((r) => r == open[index]);
      unawaited(navigator.pushReplacement(route));
    case OverListStep():
      navigator.popUntil((r) => r.isFirst);
      unawaited(navigator.push(route));
  }
  await route.popped;
  container.read(conversationMemoryProvider).closed(target);
}

/// Closes the channel [channelId] of [url] and its threads wherever they
/// show, in routes or panes, once the user is no longer in it, with the
/// pages open over them.
void closeChannel(
  NavigatorState navigator, {
  required String url,
  required String channelId,
}) {
  if (!navigator.mounted) return;
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  container.read(openPanesProvider.notifier).close(url, channelId);
  final lowest = container
      .read(conversationRoutesProvider)
      .live
      .where(
        (r) =>
            r.navigator == navigator &&
            r.target.url == url &&
            r.target.channelId == channelId,
      )
      .firstOrNull;
  container.read(paneRoutesProvider).navigator?.popUntil((r) => r.isFirst);
  if (lowest == null) return;
  var passed = false;
  navigator.popUntil((route) {
    if (passed || route.isFirst) return true;
    passed = route == lowest;
    return false;
  });
}

/// Closes every conversation and the pages over them, in routes and panes,
/// so the list shows.
void closeConversations(NavigatorState navigator) {
  if (!navigator.mounted) return;
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  for (final routes in [
    container.read(paneRoutesProvider),
    container.read(conversationRoutesProvider),
  ]) {
    routes.navigator?.popUntil((route) => route.isFirst);
  }
  container.read(openPanesProvider.notifier).set(Panes.none);
}

/// Opens [target] again the way [openConversation] first did.
Future<void> reopenConversation(
  NavigatorState navigator,
  ConversationTarget target, {
  bool instant = false,
}) => switch (target) {
  ChannelTarget() => openConversation(
    navigator,
    url: target.url,
    channelId: target.channelId,
    title: target.title,
    teamId: target.teamId,
    instant: instant,
    recordHistory: false,
  ),
  ThreadTarget() => openConversation(
    navigator,
    url: target.url,
    channelId: target.channelId,
    title: target.channelName,
    teamId: target.teamId,
    rootId: target.rootId,
    instant: instant,
    recordHistory: false,
  ),
};

/// The route of [target] on a narrow screen.
ConversationRoute<void> conversationRoute(
  ConversationTarget target, {
  bool instant = false,
}) => ConversationRoute<void>(
  target: target,
  instant: instant,
  builder: (_) => conversationScreen(target),
);

/// The screen of [target], in a route or a pane.
Widget conversationScreen(ConversationTarget target) => switch (target) {
  ThreadTarget() => ThreadScreen(
    url: target.url,
    channelId: target.channelId,
    rootId: target.rootId,
    channelName: target.channelName,
    highlightPostId: target.highlightPostId,
    focusComposer: target.focusComposer,
  ),
  ChannelTarget() => ChannelScreen(
    url: target.url,
    channelId: target.channelId,
    title: target.title,
    highlightPostId: target.highlightPostId,
    focusComposer: target.focusComposer,
  ),
};

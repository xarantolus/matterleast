import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/channel/reading_places.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/place_view.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_history.g.dart';

/// Where the user went, across teams and servers, for Back and Forward.
@Riverpod(keepAlive: true)
OpenHistory<Location> openHistory(Ref ref) =>
    OpenHistory(repeats: (entry, current) => entry.repeats(current));

/// The rail's place, the conversation on top and where it is read.
Location shownLocation(ProviderContainer container) {
  final open = conversationToSave(
    Panes.openNow(
      routes: [
        for (final r in container.read(conversationRoutesProvider).live)
          r.target,
      ],
      panes: container.read(openPanesProvider),
    ),
  );
  final place = container.read(railSelectionProvider);
  final view = _pageOver(container)?.view;
  if (view != null && open?.rootId == null) {
    return Location(place: place, view: view);
  }
  return Location(
    place: place,
    conversation: open,
    at: open == null
        ? null
        : container.read(readingPlacesProvider).placeOf(_keyOf(open)),
  );
}

/// The content page over the conversations, if one is.
SlideRoute<dynamic>? _pageOver(ProviderContainer container) {
  final page =
      container.read(paneRoutesProvider).stack.lastOrNull ??
      container.read(conversationRoutesProvider).stack.lastOrNull;
  return page is ConversationRoute ? null : page;
}

ConversationKey _keyOf(SavedConversation c) =>
    (url: c.url, channelId: c.channelId, rootId: c.rootId);

/// Records where the user is, before they go elsewhere.
void settleLocation(ProviderContainer container) => settleHistory(
  container.read(openHistoryProvider),
  shownLocation(container),
);

/// Goes one entry back or forward through the normal open path.
Future<void> stepHistory(
  ProviderContainer container, {
  required bool forward,
}) async {
  final routes = container.read(conversationRoutesProvider);
  final navigator = routes.navigator;
  if (navigator == null || _stepping) return;
  if (routes.modalOnTop) {
    // Back closes what covers the window; it never moves the places under it.
    if (!forward) unawaited(navigator.maybePop());
    return;
  }
  final history = container.read(openHistoryProvider);
  final shown = shownLocation(container);
  noteReading(history, shown);
  final page = _pageOver(container);
  final move = historyMove(
    forward: forward,
    pageOnTop: page != null && page.view == null,
    shown: shown,
    current: history.current,
  );
  if (move == HistoryMove.closePage) {
    unawaited(page?.navigator?.maybePop());
    return;
  }
  _stepping = true;
  try {
    final servers = await readOnceIn(container, serversProvider.future);
    final signedIn = {
      for (final s in servers)
        if (s.signedIn) s.url,
    };
    final channels = await _joinedChannels(container, {
      for (final e in history.entries)
        if (e.conversation?.url case final url? when signedIn.contains(url))
          url,
    });
    final teams = await _teamsOf(container, {
      for (final e in history.entries)
        if (e.place?.url case final url? when signedIn.contains(url)) url,
    });
    bool exists(Location e) =>
        locationExists(e, signedIn: signedIn, channels: channels, teams: teams);
    final current = history.current;
    final entry =
        move == HistoryMove.reopenCurrent && current != null && exists(current)
        ? current
        : history.step(forward: forward, exists: exists);
    if (entry == null || !navigator.mounted) return;
    _show(container, navigator, entry);
  } finally {
    _stepping = false;
  }
}

var _stepping = false;

void _show(
  ProviderContainer container,
  NavigatorState navigator,
  Location entry,
) {
  final conversation = entry.conversation;
  if (conversation == null) {
    container.read(railSelectionProvider.notifier).select(entry.place);
    closePages(navigator);
    if (entry.view case final view?) {
      unawaited(_showView(container, navigator, entry.place, view));
    }
    return;
  }
  final at = entry.at;
  if (entry.highlightPostId == null && at != null) {
    container.read(readingPlacesProvider).restore(_keyOf(conversation), at);
  }
  unawaited(
    openConversation(
      navigator,
      url: conversation.url,
      channelId: conversation.channelId,
      title: conversation.title,
      teamId: conversation.teamId,
      rootId: conversation.rootId,
      highlightPostId: entry.highlightPostId,
      recordHistory: false,
    ),
  );
  // Back to a channel closes the thread the panes kept.
  if (conversation.rootId == null) {
    container.read(openPanesProvider.notifier).closeThread();
  }
}

Future<void> _showView(
  ProviderContainer container,
  NavigatorState navigator,
  RailTarget? place,
  PlaceView view,
) async {
  if (place == null) return;
  container.read(openPanesProvider.notifier).closeThread();
  final teams = await readOnceIn(
    container,
    railTeamsProvider(place.url).future,
  );
  final id = shownTeam(place, teams);
  if (id == null || !navigator.mounted) return;
  await openPlaceView(
    navigator,
    view,
    url: place.url,
    teamId: id,
    teamName: teams.firstWhere((t) => t.id == id).displayName,
    recordHistory: false,
  );
}

/// The teams each server has; a server that couldn't be asked is missing.
Future<Map<String, Set<String>>> _teamsOf(
  ProviderContainer container,
  Set<String> urls,
) async {
  final result = <String, Set<String>>{};
  for (final url in urls) {
    try {
      final teams = await readOnceIn(
        container,
        railTeamsProvider(url).future,
      ).timeout(const Duration(seconds: 5));
      result[url] = {for (final t in teams) t.id};
    } on Object catch (e) {
      Log.warn('history', 'Could not check the teams of a server', e);
    }
  }
  return result;
}

/// Joined, unarchived channels per server; a server that couldn't be asked is missing.
Future<Map<String, Set<String>>> _joinedChannels(
  ProviderContainer container,
  Set<String> urls,
) async {
  final result = <String, Set<String>>{};
  for (final url in urls) {
    try {
      final items = await readOnceIn(
        container,
        switchItemsProvider(url).future,
      ).timeout(const Duration(seconds: 5));
      result[url] = {
        for (final i in items)
          if (i.joined && i.kind != SwitchKind.archived) i.id,
      };
    } on Object catch (e) {
      Log.warn('history', 'Could not check the channels of a server', e);
    }
  }
  return result;
}

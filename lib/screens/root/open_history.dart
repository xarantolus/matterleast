import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/channel/reading_places.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_history.g.dart';

/// Where the user went, across teams and servers, for the mouse's Back and
/// Forward buttons, Alt+Left and Alt+Right and the touchpad swipe.
@Riverpod(keepAlive: true)
OpenHistory<Location> openHistory(Ref ref) =>
    OpenHistory(repeats: (entry, current) => entry.repeats(current));

/// Where the user is now: the rail's place, the conversation on top and
/// where it is read.
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
  return Location(
    place: container.read(railSelectionProvider),
    conversation: open,
    at: open == null
        ? null
        : container.read(readingPlacesProvider).placeOf(_keyOf(open)),
  );
}

ConversationKey _keyOf(SavedConversation c) =>
    (url: c.url, channelId: c.channelId, rootId: c.rootId);

/// Notes where the user is, before they go somewhere else.
void settleLocation(ProviderContainer container) => settleHistory(
  container.read(openHistoryProvider),
  shownLocation(container),
);

/// Goes to the entry before (or after) the one shown, through the normal
/// open path, so the rail moves to its server and team and the reader is
/// where they were. One step at a time.
Future<void> stepHistory(
  ProviderContainer container, {
  required bool forward,
}) async {
  final navigator = container.read(conversationRoutesProvider).navigator;
  if (navigator == null || _stepping) return;
  _stepping = true;
  try {
    final history = container.read(openHistoryProvider);
    noteReading(history, shownLocation(container));
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
    final entry = history.step(
      forward: forward,
      exists: (e) => locationExists(e, signedIn: signedIn, channels: channels),
    );
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
  // A channel opened in the panes keeps its thread; Back to the channel
  // closes it.
  if (conversation.rootId == null) {
    container.read(openPanesProvider.notifier).closeThread();
  }
}

/// The channels each server has now that the user is in and aren't
/// archived; a server missing from the result couldn't be asked.
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

import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_history.g.dart';

/// What the user opened, across teams and servers, for the mouse's Back
/// and Forward buttons and Alt+Left and Alt+Right.
@Riverpod(keepAlive: true)
OpenHistory<SavedConversation> openHistory(Ref ref) => OpenHistory();

/// Opens the conversation before (or after) the one shown, through the
/// normal open path, so the rail moves to its team. One step at a time.
Future<void> stepHistory(
  ProviderContainer container, {
  required bool forward,
}) async {
  final navigator = container.read(conversationRoutesProvider).navigator;
  if (navigator == null || _stepping) return;
  _stepping = true;
  try {
    final history = container.read(openHistoryProvider);
    final existing = await _existingChannels(container, {
      for (final e in history.entries) e.url,
    });
    final entry = history.step(
      forward: forward,
      exists: (e) => existing[e.url]?.contains(e.channelId) ?? true,
    );
    if (entry == null || !navigator.mounted) return;
    unawaited(
      openConversation(
        navigator,
        url: entry.url,
        channelId: entry.channelId,
        title: entry.title,
        teamId: entry.teamId,
        rootId: entry.rootId,
        recordHistory: false,
      ),
    );
  } finally {
    _stepping = false;
  }
}

var _stepping = false;

/// The channels each server has now; a server missing from the result
/// couldn't be asked, so its entries stay.
Future<Map<String, Set<String>>> _existingChannels(
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
          if (i.kind != SwitchKind.person) i.id,
      };
    } on Object catch (e) {
      Log.warn('history', 'Could not check the channels of a server', e);
    }
  }
  return result;
}

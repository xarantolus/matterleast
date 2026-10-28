import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/search/search_providers.dart';

/// Opens the conversation the user last had open in the place the rail
/// shows, over the channel list it belongs to, unless [launchedByIntent] says a notification, link or share
/// launched the app. Then starts remembering what is open.
Future<void> restoreConversation(
  WidgetRef ref,
  NavigatorState navigator, {
  required Future<bool> launchedByIntent,
}) async {
  try {
    final store = ref.read(settingsStoreProvider);
    final open = await store.read(Settings.openConversations);
    final saved = open.at(await store.read(Settings.lastRailTarget));
    final stack = await _stackOf(ref, saved, await launchedByIntent);
    if (stack.isNotEmpty && navigator.mounted) {
      for (final target in stack) {
        unawaited(reopenConversation(navigator, target, instant: true));
      }
    }
  } on Object catch (e) {
    Log.warn('launch', 'Restoring the open conversation failed', e);
  }
  if (navigator.mounted) {
    await ref.read(conversationMemoryProvider).start();
  }
}

Future<List<ConversationTarget>> _stackOf(
  WidgetRef ref,
  SavedConversation? saved,
  bool launchedByIntent,
) async {
  if (saved == null || launchedByIntent) return const [];
  return openableStack(ProviderScope.containerOf(ref.context), saved);
}

/// The conversations that open [saved] again, its channel first when it is
/// a thread; none when its server is signed out or its channel left, gone
/// or archived since.
Future<List<ConversationTarget>> openableStack(
  ProviderContainer container,
  SavedConversation saved,
) async {
  final servers = await readOnceIn(container, serversProvider.future);
  final signedIn = {
    for (final s in servers)
      if (s.signedIn) s.url,
  };
  if (!signedIn.contains(saved.url)) return const [];
  final items = await readOnceIn(
    container,
    switchItemsProvider(saved.url).future,
  ).timeout(const Duration(seconds: 5));
  return conversationsToRestore(
    saved: saved,
    launchedByIntent: false,
    signedInUrls: signedIn,
    channels: {
      for (final i in items)
        if (i.kind != SwitchKind.person) i.id: i,
    },
  );
}

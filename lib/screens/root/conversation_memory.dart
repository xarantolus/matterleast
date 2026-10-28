import 'dart:async';

import 'package:matterleast/app/desktop/window_title.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_memory.g.dart';

/// Writes the conversation on top to the settings whenever the open ones
/// change, in routes on a narrow window or in panes on a wide one, so the
/// next launch can open it again. Read it once the launch has restored.
@Riverpod(keepAlive: true)
ConversationMemory conversationMemory(Ref ref) {
  final memory = ConversationMemory(
    store: ref.watch(settingsStoreProvider),
    routes: ref.watch(conversationRoutesProvider),
    panes: () => ref.read(openPanesProvider),
    onOpen: ref.read(openConversationProvider.notifier).set,
  );
  ref.listen(openPanesProvider, (_, _) => memory.update());
  final changes = memory.routes.changes.listen((_) => memory.update());
  ref.onDispose(() => unawaited(changes.cancel()));
  return memory;
}

class ConversationMemory {
  ConversationMemory({
    required this.store,
    required this.routes,
    required this.panes,
    this.onOpen,
  });

  final SettingsStore store;
  final ConversationRoutes routes;
  final Panes Function() panes;
  final void Function(SavedConversation?)? onOpen;

  /// What the settings hold now.
  SavedConversation? saved;

  /// Reads what the last run saved, then keeps it current; called once the
  /// launch has restored, so the empty state before never overwrites it.
  Future<void> start() async {
    saved = await store.read(Settings.lastConversation);
    update();
  }

  void update() {
    final open = Panes.openNow(
      routes: [for (final r in routes.live) r.target],
      panes: panes(),
    );
    final now = conversationToSave(open);
    onOpen?.call(now);
    if (now == saved) return;
    saved = now;
    unawaited(store.write(Settings.lastConversation, now));
  }
}

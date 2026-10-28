import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_memory.g.dart';

/// Writes the conversation on top, for the place the rail shows, to the
/// settings whenever the open ones change, in routes on a narrow window or
/// in panes on a wide one, so switching back to that place and the next
/// launch can open it again. Read it once the launch has restored.
@Riverpod(keepAlive: true)
ConversationMemory conversationMemory(Ref ref) {
  final memory = ConversationMemory(
    store: ref.watch(settingsStoreProvider),
    routes: ref.watch(conversationRoutesProvider),
    panes: () => ref.read(openPanesProvider),
    place: () => ref.read(railSelectionProvider),
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
    required this.place,
  });

  final SettingsStore store;
  final ConversationRoutes routes;
  final Panes Function() panes;
  final RailTarget? Function() place;

  /// What the settings hold now; null until [start].
  OpenConversations? saved;

  /// Reads what the last run saved, then keeps it current; called once the
  /// launch has restored, so the empty state before never overwrites it.
  Future<void> start() async {
    saved = await store.read(Settings.openConversations);
    update();
  }

  /// What was open last in [place].
  SavedConversation? at(RailTarget? place) => saved?.at(place);

  /// What the place the rail shows closed last.
  SavedConversation? closedHere() => saved?.closedAt(place());

  /// The user closed [target]; a swipe in its place brings it back.
  void closed(ConversationTarget target) {
    final before = saved;
    final conversation = conversationToSave(Panes.fromStack([target]));
    if (before == null || conversation == null) return;
    final here = place();
    if (!belongsTo(conversation, here)) return;
    _save(before.withClosed(here, conversation));
  }

  void update() {
    final before = saved;
    if (before == null) return;
    final open = conversationToSave(
      Panes.openNow(
        routes: [for (final r in routes.live) r.target],
        panes: panes(),
      ),
    );
    final here = place();
    // Still the last place's, on its way out after a switch.
    if (open != null && !belongsTo(open, here)) return;
    _save(before.withOpen(here, open));
  }

  void _save(OpenConversations now) {
    if (now == saved) return;
    saved = now;
    unawaited(store.write(Settings.openConversations, now));
  }
}

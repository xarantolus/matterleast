import 'dart:math' as math;
import 'dart:typed_data';

import 'package:conversation_shortcuts/conversation_shortcuts.dart';
import 'package:matterleast/domain/quick_switch.dart';

/// How many recent conversations are published as shortcuts, at most; the
/// launcher icon shows the first few and Direct Share the rest.
const shortcutCount = 8;

const _conversationKinds = {
  SwitchKind.channel,
  SwitchKind.privateChannel,
  SwitchKind.direct,
  SwitchKind.group,
};

/// Pure: the conversations most recently viewed on any server, newest
/// first; muted ones are left out.
List<SwitchItem> recentConversations(
  List<SwitchItem> items, {
  int count = shortcutCount,
}) {
  final viewed = [
    for (final item in items)
      if (item.lastViewedAt != null &&
          !item.muted &&
          _conversationKinds.contains(item.kind))
        item,
  ]..sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
  return viewed.take(count).toList();
}

/// A shortcut's id: the server and the channel it opens.
String shortcutId(String serverUrl, String channelId) =>
    '$serverUrl\n$channelId';

String shortcutType(SwitchItem item) => shortcutId(item.serverUrl, item.id);

/// The server and channel of a shortcut; null for anything else.
({String url, String channelId})? parseShortcutType(String type) {
  final parts = type.split('\n');
  if (parts.length != 2 || parts.any((p) => p.isEmpty)) return null;
  return (url: parts[0], channelId: parts[1]);
}

/// Pure: the conversation a shortcut [id] names, among the [items] of its
/// server; null when the id is not ours, its server is not signed in or the
/// conversation is gone. The id comes from another app or the launcher, so
/// nothing in it is trusted.
SwitchItem? shortcutItem(
  String? id, {
  required Set<String> signedIn,
  required List<SwitchItem> items,
}) {
  final target = id == null ? null : parseShortcutType(id);
  if (target == null || !signedIn.contains(target.url)) return null;
  return items
      .where(
        (i) =>
            i.serverUrl == target.url &&
            i.id == target.channelId &&
            _conversationKinds.contains(i.kind),
      )
      .firstOrNull;
}

/// Pure: the [published] shortcuts to withdraw: those of a server that is
/// no longer signed in, and, for a server whose conversations are [loaded],
/// those of a conversation the user is no longer in. Muted ones stay: a
/// mention still notifies from them.
Set<String> shortcutsToRemove(
  Set<String> published, {
  required Set<String> signedIn,
  required Set<String> loaded,
  required List<SwitchItem> items,
}) {
  final known = {
    for (final i in items)
      if (_conversationKinds.contains(i.kind)) shortcutType(i),
  };
  bool stale(String id) {
    final target = parseShortcutType(id);
    if (target == null) return true;
    return !signedIn.contains(target.url) ||
        (loaded.contains(target.url) && !known.contains(id));
  }

  return {
    for (final id in published)
      if (stale(id)) id,
  };
}

/// Publishes the user's recent conversations as Android shortcuts: the
/// launcher icon's long-press menu, Direct Share targets, and what lets a
/// notification sit under Conversations. Android only.
class ShortcutPublisher {
  ShortcutPublisher({
    required this.iconOf,
    this.shortcuts = const ConversationShortcuts(),
  });

  final ConversationShortcuts shortcuts;

  /// The round picture of a conversation; null for none.
  final Future<Uint8List?> Function(SwitchItem item) iconOf;

  String? _shown;

  /// Publishes [items] of all [signedIn] servers, [loaded] being those whose
  /// conversations have arrived.
  Future<void> publish(
    List<SwitchItem> items, {
    required Set<String> signedIn,
    required Set<String> loaded,
  }) async {
    final max = math.min(shortcutCount, await shortcuts.maxCount());
    if (max == 0) return;
    final recent = recentConversations(items, count: max);
    final key = [
      for (final i in recent) '${shortcutType(i)}\t${i.title}',
      '${items.length}',
      ...signedIn,
      ...loaded,
    ].join('\n');
    if (key == _shown) return;
    _shown = key;
    final stale = shortcutsToRemove(
      await shortcuts.published(),
      signedIn: signedIn,
      loaded: loaded,
      items: items,
    );
    if (stale.isNotEmpty) await shortcuts.remove(stale);
    // Android puts a pushed shortcut first, so the newest goes last.
    for (final (rank, item) in recent.indexed.toList().reversed) {
      await shortcuts.push(
        ShortcutSpec(
          id: shortcutType(item),
          label: item.title,
          rank: rank,
          icon: await iconOf(item),
          group: item.kind == SwitchKind.group,
        ),
      );
    }
  }
}

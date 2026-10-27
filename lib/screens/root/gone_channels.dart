import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/conversation_stack.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/search/search_providers.dart';

/// Closes an open conversation once the user is no longer in its channel,
/// or the channel was archived while the server hides archived channels,
/// and says why. Only a channel seen in the list while open counts, so a
/// conversation opened before its channel is stored stays.
class GoneChannels {
  GoneChannels(this.ref, this.navigator);

  final WidgetRef ref;
  final NavigatorState navigator;
  final _sources = <String, List<ProviderSubscription<Object?>>>{};
  final _seen = <(String, String)>{};
  final _held = <ProviderSubscription<Object?>>[];
  StreamSubscription<void>? _routes;

  void start() {
    _routes = ref
        .read(conversationRoutesProvider)
        .changes
        .listen((_) => _follow());
    _held
      ..add(ref.listenManual(openPanesProvider, (_, _) => _follow()))
      // Held, so whether the server is signed in is known when it counts.
      ..add(ref.listenManual(serversProvider, (_, _) {}));
    _follow();
  }

  void dispose() {
    unawaited(_routes?.cancel());
    for (final s in _held) {
      s.close();
    }
    for (final subscriptions in _sources.values) {
      for (final s in subscriptions) {
        s.close();
      }
    }
  }

  List<ConversationTarget> get _open {
    final panes = ref.read(openPanesProvider);
    return [
      for (final r in ref.read(conversationRoutesProvider).live) r.target,
      ?panes.channel,
      ?panes.thread,
    ];
  }

  void _follow() {
    final open = _open;
    final urls = {for (final t in open) t.url};
    for (final url in [..._sources.keys]) {
      if (urls.contains(url)) continue;
      for (final s in _sources.remove(url)!) {
        s.close();
      }
    }
    for (final url in urls) {
      _sources.putIfAbsent(
        url,
        () => [
          ref.listenManual(switchItemsProvider(url), (_, _) => _check(url)),
          ref.listenManual(featuresProvider(url), (_, _) => _check(url)),
        ],
      );
    }
    _seen.removeWhere((seen) => !open.any((t) => (t.url, t.channelId) == seen));
    urls.forEach(_check);
  }

  void _check(String url) {
    final items = ref.read(switchItemsProvider(url)).value;
    if (items == null || !navigator.mounted) return;
    final archivedShown =
        ref.read(featuresProvider(url)).value?.archivedChannels ?? true;
    final channels = {
      for (final i in items)
        if (i.kind != SwitchKind.person) i.id: i,
    };
    final open = {
      for (final t in _open)
        if (t.url == url)
          t.channelId: switch (t) {
            ChannelTarget(:final title) => title,
            ThreadTarget(:final channelName) => channelName,
          },
    };
    for (final MapEntry(key: id, value: title) in open.entries) {
      final gone = channelGone(channels[id], archivedShown: archivedShown);
      if (gone == null) {
        _seen.add((url, id));
        continue;
      }
      if (!_seen.remove((url, id))) continue;
      closeChannel(navigator, url: url, channelId: id);
      final signedIn =
          ref
              .read(serversProvider)
              .value
              ?.any((s) => s.url == url && s.signedIn) ??
          false;
      if (!signedIn) continue;
      ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
        SnackBar(
          content: Text(switch (gone) {
            ChannelGone.removed => 'You were removed from $title.',
            ChannelGone.archived => '$title was archived.',
          }),
        ),
      );
    }
  }
}

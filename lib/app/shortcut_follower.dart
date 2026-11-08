import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/conversation_tile.dart';
import 'package:matterleast/notifications/notice_format.dart';
import 'package:matterleast/screens/search/search_providers.dart';

/// Keeps the Android shortcuts in step with the conversations of every
/// signed-in server.
class ShortcutFollower {
  ShortcutFollower(this._ref) {
    _publisher = ShortcutPublisher(iconOf: _iconOf);
  }

  final WidgetRef _ref;
  late final ShortcutPublisher _publisher;
  final _items = <String, List<SwitchItem>>{};
  final _sources = <ProviderSubscription<Object?>>[];
  ProviderSubscription<Object?>? _servers;
  var _queue = Future<void>.value();

  void start() {
    if (isDesktop) return;
    final servers = _ref.listenManual(serversProvider, (_, next) {
      if (next case AsyncData(:final value)) {
        _follow({
          for (final s in value)
            if (s.signedIn) s.url,
        });
      }
    }, fireImmediately: true);
    _servers = servers;
  }

  void _follow(Set<String> urls) {
    _closeSources();
    _items.clear();
    for (final url in urls) {
      final source = _ref.listenManual(switchItemsProvider(url), (_, next) {
        if (next case AsyncData(:final value)) {
          _items[url] = value;
          _publish(urls);
        }
      }, fireImmediately: true);
      _sources.add(source);
    }
    _publish(urls);
  }

  void _publish(Set<String> urls) {
    final items = [for (final list in _items.values) ...list];
    final loaded = _items.keys.toSet();
    _queue = _queue
        .then((_) => _publisher.publish(items, signedIn: urls, loaded: loaded))
        .catchError((Object e) => Log.warn('shortcuts', 'Not published', e));
  }

  /// A DM's cached picture, else a tile with the conversation's letter.
  Future<Uint8List?> _iconOf(SwitchItem item) async {
    final userId = item.userId;
    if (item.kind == SwitchKind.direct && userId != null) {
      final caches = await _ref.read(
        serverImageCachesProvider(item.serverUrl).future,
      );
      final url = serverUri(
        Uri.parse(item.serverUrl),
        'api/v4/users/$userId/image',
        {'_': '${item.pictureUpdate ?? 0}'},
      );
      final cached = await caches.identity.getFileFromCache(url.toString());
      if (cached != null) {
        final round = roundAvatar(await cached.file.readAsBytes());
        if (round != null) return round;
      }
    }
    return conversationTile(item.title);
  }

  void _closeSources() {
    for (final s in _sources) {
      s.close();
    }
    _sources.clear();
  }

  void dispose() {
    _servers?.close();
    _closeSources();
  }
}

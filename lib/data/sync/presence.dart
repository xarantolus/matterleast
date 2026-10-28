import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/teams.dart';

/// Fetches the presence of the people shown (direct message partners and
/// the user) every minute while the app is in the foreground. Others'
/// presence never comes over the WebSocket.
///
/// Presence is only true while the server is [live]: [known] holds the
/// people whose presence the server told since it last became live, and
/// empties when it stops being live, so a stored status from before never
/// shows as current.
class PresencePoller {
  PresencePoller({
    required this.server,
    required this.store,
    required this.runner,
    required this.live,
    this.interval = const Duration(seconds: 60),
  });

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final ValueListenable<bool> live;
  final Duration interval;

  final _known = ValueNotifier<Set<String>>(const {});
  var _period = 0;

  /// People whose stored presence is current.
  ValueListenable<Set<String>> get known => _known;

  /// The server stopped being live: nobody's presence is known any more.
  void forget() {
    _period++;
    if (_known.value.isNotEmpty) _known.value = const {};
  }

  /// The server told the presence of [ids] while live.
  void confirm(Iterable<String> ids) {
    if (!live.value) return;
    final added = ids.toSet().difference(_known.value);
    if (added.isNotEmpty) _known.value = {..._known.value, ...added};
  }

  /// Fetches now, such as when the server became live again.
  void refresh() {
    if (_timer != null) _poll();
  }

  static const maxIds = 200;

  Timer? _timer;
  final _shown = <String, int>{};

  ServerDatabase get _db => store.db;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => _poll());
    _poll();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => _known.dispose();

  /// Also polls [ids], such as the people a list shows, until the returned
  /// function is called.
  void Function() show(Iterable<String> ids) {
    final added = ids.toSet();
    var fresh = false;
    for (final id in added) {
      final count = (_shown[id] ?? 0) + 1;
      _shown[id] = count;
      if (count == 1) fresh = true;
    }
    if (fresh && _timer != null) _poll();
    return () {
      for (final id in added) {
        final count = (_shown[id] ?? 1) - 1;
        if (count <= 0) {
          _shown.remove(id);
        } else {
          _shown[id] = count;
        }
      }
    };
  }

  void _poll() => unawaited(
    runner
        .enqueue(
          SyncJob(
            key: 'presence',
            priority: SyncPriority.p2,
            visible: false,
            run: _fetch,
          ),
        )
        .catchError((Object _) {}),
  );

  Future<void> _fetch() async {
    final period = _period;
    final ids = await _shownUsers();
    if (ids.isEmpty) return;
    final statuses = await server.call(
      () => server.client.status.getUsersStatusesByIds(body: ids),
    );
    final byUser = {
      for (final s in statuses)
        if (s.userId != null && s.status != null) s.userId!: s.status!,
    };
    // Users the server leaves out are offline.
    await store.applyStatuses({
      for (final id in ids) id: byUser[id] ?? 'offline',
    });
    // An answer that started before the server stopped being live may
    // already be out of date.
    if (period == _period) confirm(ids);
  }

  Future<List<String>> _shownUsers() async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) return const [];
    final direct = await (_db.select(
      _db.channels,
    )..where((c) => c.type.equals('D'))).get();
    final ids = {
      me,
      for (final c in direct) ?directPartnerId(c.name, me),
      ..._shown.keys,
    };
    return ids.take(maxIds).toList();
  }
}

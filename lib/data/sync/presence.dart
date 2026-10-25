import 'dart:async';

import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/teams.dart';

/// Fetches the presence of the people shown (direct message partners and
/// the user) every minute while the app is in the foreground. Others'
/// presence never comes over the WebSocket.
class PresencePoller {
  PresencePoller({
    required this.server,
    required this.store,
    required this.runner,
    this.interval = const Duration(seconds: 60),
  });

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final Duration interval;

  static const maxIds = 200;

  Timer? _timer;

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
  }

  Future<List<String>> _shownUsers() async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) return const [];
    final direct = await (_db.select(
      _db.channels,
    )..where((c) => c.type.equals('D'))).get();
    final ids = {me, for (final c in direct) ?directPartnerId(c.name, me)};
    return ids.take(maxIds).toList();
  }
}

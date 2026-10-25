import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/event_applier.dart';
import 'package:matterleast/data/sync/presence.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

/// Keeps one server's database current while the app is in the foreground:
/// the WebSocket, the entry sync it triggers and presence polling. It goes
/// quiet 15 s after the app goes to the background.
class ServerConnection {
  ServerConnection({
    required Uri url,
    required this.server,
    required this.store,
    required this.runner,
    required String? Function() token,
    Duration pingInterval = const Duration(seconds: 30),
  }) {
    entry = EntrySync(server: server, store: store, runner: runner);
    events = EventApplier(
      server: server,
      store: store,
      runner: runner,
      entry: entry,
    );
    presence = PresencePoller(server: server, store: store, runner: runner);
    socket = ServerSocket(
      serverUrl: url,
      token: token,
      pingInterval: pingInterval,
      onEvent: (event) => unawaited(events.add(event)),
      onResync: _sync,
      onClosed: (failCount) {
        // REST may work where the socket doesn't; try once per outage.
        if (failCount == 1) _sync();
      },
    );
  }

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  late final EntrySync entry;
  late final EventApplier events;
  late final PresencePoller presence;
  late final ServerSocket socket;

  static const backgroundGrace = Duration(seconds: 15);

  Timer? _startTimer;
  Timer? _stopTimer;
  var _active = false;

  ValueListenable<SocketState> get state => socket.state;

  /// Connects after [delay] (other servers are staggered behind the one the
  /// user looks at).
  void foreground({Duration delay = Duration.zero}) {
    _stopTimer?.cancel();
    if (_active) return;
    _startTimer?.cancel();
    _startTimer = Timer(delay, () {
      _active = true;
      socket.start();
      presence.start();
    });
  }

  void background() {
    _startTimer?.cancel();
    _stopTimer?.cancel();
    _stopTimer = Timer(backgroundGrace, () => unawaited(_stop()));
  }

  void _sync() => unawaited(entry.run().catchError((Object _) {}));

  Future<void> _stop() async {
    _active = false;
    presence.stop();
    await socket.stop();
  }

  Future<void> close() async {
    _startTimer?.cancel();
    _stopTimer?.cancel();
    await _stop();
    await socket.dispose();
  }
}

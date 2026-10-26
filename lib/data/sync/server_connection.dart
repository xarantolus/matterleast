import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/live/dialogs.dart';
import 'package:matterleast/data/live/typing.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/event_applier.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/presence.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';

/// Keeps one server's database current while the app is in the foreground:
/// the WebSocket, the entry sync it triggers and presence polling. It goes
/// quiet 15 s after the app goes to the background.
class ServerConnection {
  ServerConnection({
    required Uri url,
    required this.server,
    required this.store,
    required this.runner,
    required this.users,
    required String? Function() token,
    Duration pingInterval = const Duration(seconds: 30),
  }) {
    entry = EntrySync(
      server: server,
      store: store,
      runner: runner,
      users: users,
    );
    inbox = InboxSync(
      server: server,
      store: store,
      runner: runner,
      users: users,
    );
    events = EventApplier(
      server: server,
      store: store,
      runner: runner,
      users: users,
      entry: entry,
      inbox: inbox,
      typing: typing,
      dialogs: dialogs,
    );
    presence = PresencePoller(server: server, store: store, runner: runner);
    socket = ServerSocket(
      serverUrl: url,
      token: token,
      pingInterval: pingInterval,
      onEvent: (event) => unawaited(
        events.add(event).then((_) {
          if (!_applied.isClosed) _applied.add(event);
        }),
      ),
      onResync: refreshAll,
      onClosed: (failCount) {
        // REST may work where the socket doesn't; try once per outage.
        if (failCount == 1) refreshAll();
      },
    );
  }

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final UserLoader users;
  late final EntrySync entry;
  late final InboxSync inbox;
  late final EventApplier events;
  final typing = TypingTracker();
  final dialogs = DialogInbox();
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

  final _caughtUp = StreamController<void>.broadcast();
  final _applied = StreamController<ServerEvent>.broadcast();

  /// Events once they are in the database.
  Stream<ServerEvent> get applied => _applied.stream;

  /// Fires once the entry data is current again after events may have been
  /// missed; open conversations then fetch what they lack.
  Stream<void> get caughtUp => _caughtUp.stream;

  /// Events may have been missed: the entry data first, then Home's lists,
  /// which only a fresh fetch brings up to date, and open conversations.
  void refreshAll() => unawaited(
    entry
        .run()
        .then((_) {
          if (!_caughtUp.isClosed) _caughtUp.add(null);
          return inbox.refresh(force: true);
        })
        .catchError((Object _) {}),
  );

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
    typing.close();
    dialogs.close();
    await _caughtUp.close();
    await _applied.close();
  }
}

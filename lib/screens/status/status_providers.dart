import 'dart:async';

import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/status_views.dart';
import 'package:matterleast/domain/server_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_providers.g.dart';

/// Whether the server's WebSocket is up.
@riverpod
Stream<SocketState> socketState(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  final state = session.connection.state;
  final changes = StreamController<SocketState>();
  void push() => changes.add(state.value);
  state.addListener(push);
  ref.onDispose(() {
    state.removeListener(push);
    unawaited(changes.close());
  });
  push();
  yield* changes.stream;
}

/// Whether the WebSocket has been down for longer than a short blip, so
/// the list can say live updates are paused.
@riverpod
Stream<bool> socketDown(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  final state = session.connection.state;
  final changes = StreamController<bool>();
  Timer? grace;
  void push() {
    if (state.value == SocketState.connected) {
      grace?.cancel();
      grace = null;
      changes.add(false);
    } else {
      grace ??= Timer(socketDownGrace, () => changes.add(true));
    }
  }

  state.addListener(push);
  ref.onDispose(() {
    grace?.cancel();
    state.removeListener(push);
    unawaited(changes.close());
  });
  changes.add(false);
  push();
  yield* changes.stream.distinct();
}

/// How long the WebSocket may be down before the list says so.
const socketDownGrace = Duration(seconds: 5);

/// What the server has stored on this device.
@riverpod
Stream<StoredCounts> serverStorage(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* storedCounts(session.db, session.dbPath);
}

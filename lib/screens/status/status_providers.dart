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

/// What the server has stored on this device.
@riverpod
Stream<StoredCounts> serverStorage(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* storedCounts(session.db, session.dbPath);
}

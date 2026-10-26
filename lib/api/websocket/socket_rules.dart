/// Pure rules of the WebSocket connection, kept apart from the timers and
/// the channel so they can be tested on their own.
library;

import 'dart:math';

/// Wait before reconnect attempt number [failCount] (1 = first failure):
/// 3 s for the first seven, then growing by 3 s per failure up to 5 min.
/// [jitter], from -1 to 1, moves it by up to 20% either way, so clients
/// that lost the network together don't all retry in step.
Duration retryDelay(int failCount, {double jitter = 0}) {
  const step = Duration(seconds: 3);
  const cap = Duration(minutes: 5);
  final base = failCount <= 7
      ? step
      : (step * failCount > cap ? cap : step * failCount);
  return base * (1 + 0.2 * jitter.clamp(-1, 1));
}

final _random = Random();

/// [retryDelay] with a random jitter.
Duration jitteredRetryDelay(int failCount) =>
    retryDelay(failCount, jitter: _random.nextDouble() * 2 - 1);

/// The socket address for a server, resuming [connectionId] at [sequence]
/// (reliable WebSockets; an empty id asks for a new connection).
Uri socketUri(
  Uri server, {
  required String connectionId,
  required int sequence,
}) {
  final path = server.path.endsWith('/')
      ? server.path.substring(0, server.path.length - 1)
      : server.path;
  return server.replace(
    scheme: server.scheme == 'https' ? 'wss' : 'ws',
    path: '$path/api/v4/websocket',
    queryParameters: {
      'connection_id': connectionId,
      'sequence_number': '$sequence',
    },
  );
}

/// What to do with an event frame given the connection we hold.
typedef SequenceCheck = ({
  /// The server lost our connection (or this is the first one): everything
  /// missed must be fetched again.
  bool resync,

  /// An event went missing in between: drop the connection and reconnect.
  bool gap,
  String connectionId,
  int expected,
});

/// [helloId] is the connection id of a `hello` frame, null for others.
SequenceCheck checkSequence({
  required String connectionId,
  required int expected,
  required int? seq,
  String? helloId,
}) {
  var id = connectionId;
  var next = expected;
  var resync = false;
  if (helloId != null && helloId != connectionId) {
    resync = true;
    id = helloId;
    next = 0;
  }
  if (seq != next) {
    return (resync: false, gap: true, connectionId: '', expected: 0);
  }
  return (resync: resync, gap: false, connectionId: id, expected: next + 1);
}

/// Pure rules of the WebSocket connection, kept apart from the timers and
/// the channel so they can be tested on their own.
library;

/// Wait before reconnect attempt number [failCount] (1 = first failure):
/// 3 s for the first seven, then growing by 3 s per failure up to 5 min.
Duration retryDelay(int failCount) {
  const step = Duration(seconds: 3);
  if (failCount <= 7) return step;
  final grown = step * failCount;
  const cap = Duration(minutes: 5);
  return grown > cap ? cap : grown;
}

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

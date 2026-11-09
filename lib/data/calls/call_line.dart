import 'dart:async';
import 'dart:convert';

import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/api/trusted_authorities.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/socket_rules.dart';
import 'package:matterleast/log.dart';
import 'package:web_socket_channel/io.dart';

/// What the calls socket tells the call.
sealed class LineEvent {
  const LineEvent();
}

/// The socket is authenticated; [connectionId] names it.
final class LineHello extends LineEvent {
  const LineHello(this.connectionId);
  final String connectionId;
}

/// The server accepted our `join`.
final class LineJoined extends LineEvent {
  const LineJoined();
}

/// A signalling message for us: [data] is its JSON text.
final class LineSignal extends LineEvent {
  const LineSignal(this.data);
  final String data;
}

/// A failed `join` or `reconnect`, in the server's words.
final class LineError extends LineEvent {
  const LineError(this.message);
  final String message;
}

/// An event about the call from the plugin.
final class LineCall extends LineEvent {
  const LineCall(this.event);
  final CallsEvent event;
}

/// The socket is gone, whatever the reason.
final class LineClosed extends LineEvent {
  const LineClosed();
}

/// The calls socket as the call uses it: ordered events in, actions out.
abstract interface class CallLine {
  Stream<LineEvent> get events;

  /// The connection id the server gave this socket; empty before the hello.
  String get connectionId;

  /// The next server sequence number to expect, to resume with.
  int get expected;

  void send(String action, [Map<String, Object?>? data]);
  void sendSdp(String json);

  /// Sends `reconnect` once; later calls do nothing.
  void sendReconnect({
    required String channelId,
    required String originalId,
    required String previousId,
  });

  Future<void> close();
}

/// Opens a calls socket, resuming [connectionId] at [expected] after a
/// drop; [originalId] is the session's first connection id.
typedef CallLineOpener = Future<CallLine> Function({
  required String connectionId,
  required int expected,
  required String originalId,
});

/// The real calls socket: a second WebSocket to the server, with its own
/// lifecycle. It sends text actions and, for SDP, binary frames.
class CallSocket implements CallLine {
  CallSocket._(this._channel, this._originalId) {
    _subscription = _channel.stream.listen(
      _onMessage,
      onDone: _closed,
      onError: (Object _) => _closed(),
    );
  }

  static Future<CallSocket> open({
    required Uri serverUrl,
    required String? Function() token,
    required String connectionId,
    required int expected,
    required String originalId,
    Duration connectTimeout = const Duration(seconds: 5),
  }) async {
    final authorities = TrustedAuthorities.instance;
    await authorities.ready;
    final base = socketUri(
      serverUrl,
      connectionId: connectionId,
      sequence: expected,
    );
    final uri = base.replace(
      queryParameters: {...base.queryParameters, 'calls': 'true'},
    );
    final channel = IOWebSocketChannel.connect(
      uri,
      headers: {
        'Origin': serverUrl.origin,
        if (token() case final token?) 'Authorization': 'Bearer $token',
      },
      connectTimeout: connectTimeout,
      customClient: authorities.pemFor(serverUrl) == null
          ? null
          : authorities.httpClient(serverUrl),
    );
    await channel.ready;
    return CallSocket._(channel, originalId);
  }

  final IOWebSocketChannel _channel;
  final String _originalId;
  late final StreamSubscription<Object?> _subscription;
  final _events = StreamController<LineEvent>();
  var _connectionId = '';
  var _expected = 0;
  var _seq = 1;
  var _reconnectSent = false;
  var _isClosed = false;

  @override
  Stream<LineEvent> get events => _events.stream;

  @override
  String get connectionId => _connectionId;

  @override
  int get expected => _expected;

  @override
  void send(String action, [Map<String, Object?>? data]) {
    if (_isClosed) return;
    _channel.sink.add(actionFrame(action, _seq++, data));
  }

  @override
  void sendSdp(String json) {
    if (_isClosed) return;
    _channel.sink.add(sdpSocketFrame(_seq++, json));
  }

  @override
  void sendReconnect({
    required String channelId,
    required String originalId,
    required String previousId,
  }) {
    if (_reconnectSent) return;
    _reconnectSent = true;
    send('reconnect', {
      'channelID': channelId,
      'originalConnID': originalId,
      'prevConnID': previousId,
    });
  }

  void _onMessage(Object? message) {
    if (message is! String) return;
    final Object? json;
    try {
      json = jsonDecode(message);
    } on FormatException {
      return;
    }
    if (json is! Map<String, Object?>) return;
    final frame = SocketFrame.fromJson(json);
    if (frame.isReply) {
      if (frame.status == 'FAIL') Log.warn('calls', 'An action failed');
      return;
    }
    final seq = frame.seq;
    if (seq != null) _expected = seq + 1;
    final name = frame.event ?? '';
    if (name == 'hello') {
      final id = frame.data['connection_id'];
      if (id is! String || id.isEmpty) return;
      _connectionId = id;
      _events.add(LineHello(id));
      return;
    }
    if (!name.startsWith(callsActionPrefix)) return;
    final short = name.substring(callsActionPrefix.length);
    if (short == 'join' || short == 'signal' || short == 'error') {
      final target = frame.data['connID'];
      if (target != _connectionId && target != _originalId) return;
      final payload = frame.data['data'];
      switch (short) {
        case 'join':
          _events.add(const LineJoined());
        case 'signal' when payload is String:
          _events.add(LineSignal(payload));
        case 'error':
          _events.add(LineError(payload is String ? payload : ''));
      }
      return;
    }
    if (decodeEvent(frame) case final CallsEvent event) {
      _events.add(LineCall(event));
    }
  }

  void _closed() {
    if (_isClosed) return;
    _isClosed = true;
    _events.add(const LineClosed());
    unawaited(_events.close());
  }

  @override
  Future<void> close() async {
    final wasClosed = _isClosed;
    _isClosed = true;
    await _subscription.cancel();
    await _channel.sink.close();
    if (!wasClosed) await _events.close();
  }
}

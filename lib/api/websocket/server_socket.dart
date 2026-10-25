import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/socket_rules.dart';
import 'package:matterleast/log.dart';
import 'package:web_socket_channel/io.dart';

enum SocketState { disconnected, connecting, connected }

/// One server's WebSocket: connects with the token, keeps the connection
/// alive with JSON pings, reconnects with backoff and tells [onResync] when
/// events were lost so the caller fetches again over REST.
class ServerSocket {
  ServerSocket({
    required this.serverUrl,
    required this.token,
    required this.onEvent,
    required this.onResync,
    this.onClosed,
    this.pingInterval = const Duration(seconds: 30),
    this.retryDelayOf = retryDelay,
  });

  final Uri serverUrl;
  final String? Function() token;
  final void Function(ServerEvent event) onEvent;
  final void Function() onResync;

  /// Called after each failed or dropped connection with the failure count.
  final void Function(int failCount)? onClosed;
  final Duration pingInterval;
  final Duration Function(int failCount) retryDelayOf;

  final _state = ValueNotifier(SocketState.disconnected);
  ValueListenable<SocketState> get state => _state;

  IOWebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Timer? _pingTimer;
  Timer? _retryTimer;
  var _connectionId = '';
  var _expected = 0;
  var _actionSeq = 1;
  var _failCount = 0;
  var _waitingForPong = false;
  var _running = false;
  var _attempt = 0;

  /// Connects and stays connected until [stop].
  void start() {
    if (_running) return;
    _running = true;
    unawaited(_open());
  }

  /// Closes without reconnecting; [start] resumes the same connection id,
  /// so the server can replay what was missed.
  Future<void> stop() async {
    _running = false;
    _retryTimer?.cancel();
    _attempt++;
    await _drop();
    _state.value = SocketState.disconnected;
  }

  Future<void> dispose() async {
    await stop();
    _state.dispose();
  }

  Future<void> _open() async {
    final attempt = ++_attempt;
    _state.value = SocketState.connecting;
    final uri = socketUri(
      serverUrl,
      connectionId: _connectionId,
      sequence: _expected,
    );
    final channel = IOWebSocketChannel.connect(
      uri,
      headers: {
        'Origin': serverUrl.origin,
        if (token() case final token?) 'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 30),
    );
    try {
      await channel.ready;
    } on Object catch (e) {
      if (attempt != _attempt) return;
      if (_failCount == 0) Log.warn('socket', 'Connecting failed', e);
      _closed();
      return;
    }
    if (attempt != _attempt || !_running) {
      unawaited(channel.sink.close());
      return;
    }
    _channel = channel;
    _actionSeq = 1;
    _subscription = channel.stream.listen(
      _onMessage,
      onDone: () {
        if (attempt == _attempt) _closed();
      },
      onError: (Object _) {},
    );
    _state.value = SocketState.connected;
    _failCount = 0;
    if (token() case final token?) {
      _send('authentication_challenge', {'token': token});
    }
    _waitingForPong = true;
    _send('ping');
    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_waitingForPong) {
        Log.info('socket', 'No pong; reconnecting');
        unawaited(_reconnect());
        return;
      }
      _waitingForPong = true;
      _send('ping');
    });
  }

  void _send(String action, [Map<String, Object?>? data]) {
    _channel?.sink.add(
      jsonEncode({'action': action, 'seq': _actionSeq++, 'data': ?data}),
    );
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
      if (frame.isPong) _waitingForPong = false;
      if (frame.status == 'FAIL') Log.warn('socket', 'Action failed');
      return;
    }
    final check = checkSequence(
      connectionId: _connectionId,
      expected: _expected,
      seq: frame.seq,
      helloId: frame.event == 'hello'
          ? frame.data['connection_id'] as String? ?? ''
          : null,
    );
    _connectionId = check.connectionId;
    _expected = check.expected;
    if (check.gap) {
      Log.info('socket', 'Missed an event; reconnecting');
      unawaited(_reconnect());
      return;
    }
    if (check.resync) onResync();
    onEvent(decodeEvent(frame));
  }

  Future<void> _reconnect() async {
    final attempt = _attempt;
    await _drop();
    if (attempt == _attempt) _closed();
  }

  void _closed() {
    _attempt++;
    unawaited(_drop());
    _state.value = SocketState.disconnected;
    _failCount++;
    onClosed?.call(_failCount);
    if (!_running) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(retryDelayOf(_failCount), () {
      if (_running) unawaited(_open());
    });
  }

  Future<void> _drop() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    final channel = _channel;
    _channel = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    await channel?.sink.close();
  }
}

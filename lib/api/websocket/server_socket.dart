import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/trusted_authorities.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/socket_rules.dart';
import 'package:matterleast/log.dart';
import 'package:web_socket_channel/io.dart';

enum SocketState { disconnected, connecting, connected }

/// One server's WebSocket: connects with the token, keeps the connection
/// alive with JSON pings, reconnects with backoff and tells [onResync] when
/// events were lost so the caller fetches again over REST. While [online]
/// is false it waits instead of retrying, and connects again as soon as it
/// turns true. While [reachable] is false each retry only asks [probe]
/// whether the server answers, and it connects as soon as it does.
class ServerSocket {
  ServerSocket({
    required this.serverUrl,
    required this.token,
    required this.onEvent,
    required this.onResync,
    this.onClosed,
    this.pingInterval = const Duration(seconds: 30),
    this.retryDelayOf = jitteredRetryDelay,
    this.online,
    this.reachable,
    this.probe,
  }) {
    online?.addListener(_networkChanged);
    reachable?.addListener(_reachChanged);
  }

  final Uri serverUrl;
  final String? Function() token;
  final void Function(ServerEvent event) onEvent;
  final void Function() onResync;

  /// Called after each failed or dropped connection with the failure count.
  final void Function(int failCount)? onClosed;
  final Duration pingInterval;
  final Duration Function(int failCount) retryDelayOf;
  final ValueListenable<bool>? online;
  final ValueListenable<bool>? reachable;
  final Future<bool> Function()? probe;

  /// The longest wait between pings while the server doesn't answer.
  static const maxProbeDelay = Duration(seconds: 15);

  bool get _offline => !(online?.value ?? true);

  final _state = ValueNotifier(SocketState.disconnected);
  ValueListenable<SocketState> get state => _state;

  IOWebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Timer? _pingTimer;
  Timer? _retryTimer;
  Timer? _aliveCheck;
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
    final attempt = ++_attempt;
    await _drop();
    // A start while the old connection was still closing owns the state.
    if (attempt == _attempt) _state.value = SocketState.disconnected;
  }

  Future<void> dispose() async {
    online?.removeListener(_networkChanged);
    reachable?.removeListener(_reachChanged);
    await stop();
    _state.dispose();
  }

  Future<void> _open() async {
    final attempt = ++_attempt;
    _state.value = SocketState.connecting;
    final authorities = TrustedAuthorities.instance;
    await authorities.ready;
    if (attempt != _attempt || !_running) return;
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
      customClient: authorities.pemFor(serverUrl) == null
          ? null
          : authorities.httpClient(serverUrl),
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

  /// Pings now and drops the connection when no pong comes [within], for
  /// when other requests to the server went unanswered: the periodic ping
  /// alone would notice a dead connection only after a minute.
  void checkAlive({Duration within = const Duration(seconds: 5)}) {
    if (_state.value != SocketState.connected || _aliveCheck != null) return;
    _waitingForPong = true;
    _send('ping');
    _aliveCheck = Timer(within, () {
      _aliveCheck = null;
      if (!_waitingForPong) return;
      Log.info('socket', 'No pong after a request went unanswered');
      unawaited(_reconnect());
    });
  }

  /// Tells the channel (or the thread [parentId]) that the user is writing.
  /// Returns false when not connected.
  bool sendTyping(String channelId, String parentId) {
    if (_state.value != SocketState.connected) return false;
    _send('user_typing', {'channel_id': channelId, 'parent_id': parentId});
    return true;
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
    if (!_running || _offline) return;
    _retryTimer?.cancel();
    _scheduleRetry();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    var delay = retryDelayOf(_failCount);
    // A ping is cheap, so a server known to be down is asked more often
    // than a full connect would be retried.
    if (probe != null && !(reachable?.value ?? true) && delay > maxProbeDelay) {
      delay = maxProbeDelay;
    }
    _retryTimer = Timer(delay, () {
      if (_running) unawaited(_retry());
    });
  }

  /// A full connect may hang until its timeout; while the server is known
  /// not to answer, a short ping stands in for it.
  Future<void> _retry() async {
    final probe = this.probe;
    if (probe == null || (reachable?.value ?? true)) return _open();
    final attempt = _attempt;
    // On success the server counts as reachable again and
    // [_reachChanged] connects.
    if (await probe()) return;
    if (!_running || _offline || attempt != _attempt) return;
    if (_state.value != SocketState.disconnected) return;
    _failCount++;
    _scheduleRetry();
  }

  void _reachChanged() {
    if (!_running || _offline || !(reachable?.value ?? true)) return;
    if (_state.value != SocketState.disconnected) return;
    _retryTimer?.cancel();
    _failCount = 0;
    unawaited(_open());
  }

  void _networkChanged() {
    if (!_running) return;
    if (_offline) {
      _retryTimer?.cancel();
      if (_state.value != SocketState.disconnected) unawaited(_reconnect());
      return;
    }
    if (_state.value != SocketState.disconnected) return;
    // A fresh network: the backoff from the outage no longer applies.
    _retryTimer?.cancel();
    _failCount = 0;
    unawaited(_open());
  }

  Future<void> _drop() async {
    _aliveCheck?.cancel();
    _aliveCheck = null;
    _pingTimer?.cancel();
    _pingTimer = null;
    final channel = _channel;
    _channel = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    await channel?.sink.close();
  }
}

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_rules.dart';
import 'package:matterleast/log.dart';

/// One call from the user's side: the calls socket, the media connection
/// and what keeps them alive. It runs once; a finished call is replaced by
/// a new session. [connection] is what the screens render.
class CallSession {
  CallSession({
    required this.channelId,
    required this.direct,
    required this.openLine,
    required this.createPeer,
    required this.platform,
    required this.loadConfig,
    required this.loadTurn,
    required this.refreshState,
    required this.failureText,
    this.title,
    this.threadId,
    this.networkChanges,
    this.timings = const CallTimings(),
  });

  final String channelId;

  /// A direct message, where the earpiece is the usual way to listen.
  final bool direct;
  final CallLineOpener openLine;
  final CallPeerFactory createPeer;
  final CallPlatform platform;
  final Future<CallsConfig?> Function() loadConfig;
  final Future<List<CallsIceServer>> Function() loadTurn;

  /// Fetches the call's state again, for after the socket was away.
  final void Function() refreshState;

  /// Words for a failure to reach the server.
  final String Function(Object error) failureText;
  final String? title;
  final String? threadId;

  /// Fires when the device's network changed.
  final Stream<void>? networkChanges;
  final CallTimings timings;

  final connection = ValueNotifier(const CallConnection());

  CallLine? _line;
  CallPeer? _peer;
  final _subscriptions = <StreamSubscription<Object?>>[];
  StreamSubscription<LineEvent>? _lineSubscription;
  Timer? _joinTimer;
  Timer? _connectTimer;
  Timer? _restartWatch;
  Timer? _pingTimer;
  Timer? _statsTimer;

  var _finished = false;
  var _config = const CallsConfig();
  var _iceServers = <IceServer>[];
  var _sessionId = '';
  var _resumeId = '';
  var _resumeExpected = 0;
  DateTime? _droppedAt;
  var _reconnecting = false;
  var _afterReconnect = false;

  var _dcOpen = false;
  var _peerUp = false;
  var _wantMuted = true;
  var _serverMuted = true;
  var _muting = false;
  var _firstConnected = false;
  AudioRoute? _pinned;

  var _remoteReady = false;
  final _remoteQueue = <CandidateInit>[];
  final _serverCandidates = <String>[];
  final _localQueue = <CandidateInit>[];
  Completer<SignalMessage>? _answer;
  Completer<bool>? _lockReply;
  Future<void> _negotiation = Future.value();
  var _restarting = false;
  var _restarts = 0;
  DateTime? _lastRestart;
  var _awaitingPong = false;
  var _missed = 0;

  bool get _over => _finished;

  void _set(CallConnection Function(CallConnection) edit) {
    final next = edit(connection.value);
    if (next != connection.value) connection.value = next;
  }

  /// Runs the join. Everything after the first await is guarded by
  /// [_over], since the user may leave at any point.
  Future<void> start() async {
    _set((c) => c.copyWith(phase: CallPhase.preparing));
    _subscriptions
      ..add(platform.hangUps.listen((_) => unawaited(leave())))
      ..add(platform.routesChanged.listen((_) => unawaited(_syncRoutes())));
    final changes = networkChanges;
    if (changes != null) _subscriptions.add(changes.listen((_) => _network()));
    var microphone = false;
    try {
      microphone = await platform.requestMicrophone();
    } on Object catch (e) {
      Log.warn('calls', 'Asking for the microphone failed', e);
    }
    if (_over) return;
    _set((c) => c.copyWith(listenOnly: !microphone));
    try {
      await platform.prepareAudio();
    } on Object catch (e) {
      Log.warn('calls', 'Preparing the audio failed', e);
    }
    final config = await _timed(loadConfig());
    if (_over) return;
    _config = config ?? _config;
    final turn = _config.needsTurnCredentials == true
        ? await _timed(loadTurn())
        : null;
    if (_over) return;
    _iceServers = _servers(turn);
    try {
      await platform.startService(title: 'Call in progress', text: '');
    } on Object catch (e) {
      Log.warn('calls', 'Starting the call service failed', e);
    }
    if (_over) return;
    final peer = createPeer();
    _peer = peer;
    _subscriptions.add(peer.events.listen(_onPeer));
    try {
      await peer.start(iceServers: _iceServers, microphone: microphone);
    } on Object catch (e) {
      if (!microphone) {
        _fail(CallFailure(CallFailureKind.media, failureText(e)));
        return;
      }
      Log.warn('calls', 'The microphone could not be opened', e);
      await peer.close();
      if (_over) return;
      _subscriptions.removeLast();
      final listener = createPeer();
      _peer = listener;
      _subscriptions.add(listener.events.listen(_onPeer));
      _set((c) => c.copyWith(listenOnly: true));
      try {
        await listener.start(iceServers: _iceServers, microphone: false);
      } on Object catch (e) {
        _fail(CallFailure(CallFailureKind.media, failureText(e)));
        return;
      }
    }
    if (_over) return;
    final line = await _connectLine();
    if (_over) {
      await line?.close();
      return;
    }
    if (line == null) {
      _fail(
        const CallFailure(
          CallFailureKind.noConnection,
          "Couldn't connect to the call server. Check the connection and try "
          'again.',
        ),
      );
      return;
    }
    _attach(line);
  }

  Future<T?> _timed<T>(Future<T> work) async {
    try {
      return await work.timeout(timings.turnTimeout);
    } on Object catch (e) {
      Log.warn('calls', 'A call setup request failed: ${e.runtimeType}');
      return null;
    }
  }

  List<IceServer> _servers(List<CallsIceServer>? turn) => [
    for (final s in [..._config.iceServers, ...?turn])
      (urls: s.urls, username: s.username, credential: s.credential),
  ];

  /// Opens the socket, trying again within the reconnect budget.
  Future<CallLine?> _connectLine() async {
    final began = clock.now();
    while (!_over) {
      try {
        return await openLine(
          connectionId: _resumeId,
          expected: _resumeExpected,
          originalId: _sessionId,
        );
      } on Object catch (e) {
        Log.info('calls', 'The calls socket did not open: ${e.runtimeType}');
      }
      final step = reconnectStep(
        clock.now().difference(began),
        timings: timings,
      );
      if (step is! ReconnectIn) return null;
      await Future<void>.delayed(step.delay);
    }
    return null;
  }

  void _attach(CallLine line) {
    _line = line;
    _lineSubscription = line.events.listen(
      (e) => _onLine(line, e),
      onDone: () => _onLine(line, const LineClosed()),
    );
  }

  void _onLine(CallLine line, LineEvent event) {
    if (_over || line != _line) return;
    switch (event) {
      case LineHello(:final connectionId):
        _onHello(line, connectionId);
      case LineJoined():
        _joinTimer?.cancel();
        unawaited(_firstOffer());
      case LineSignal(:final data):
        if (SignalMessage.parse(data) case final message?) {
          _onSignal(message);
        }
      case LineError(:final message):
        _fail(
          _afterReconnect
              ? reconnectRefusal(message)
              : CallFailure(
                  CallFailureKind.server,
                  message.isEmpty ? 'The server refused the call.' : message,
                ),
        );
      case LineCall(:final event):
        _onCallEvent(event);
      case LineClosed():
        _onLineClosed(line);
    }
  }

  void _onHello(CallLine line, String connectionId) {
    if (_sessionId.isEmpty) {
      _sessionId = connectionId;
      _set(
        (c) => c.copyWith(phase: CallPhase.joining, sessionId: connectionId),
      );
      _joinTimer = Timer(timings.joinTimeout, () {
        _fail(
          const CallFailure(
            CallFailureKind.timeout,
            "The call server didn't answer. Try again.",
          ),
        );
      });
      line.send('join', {
        'channelID': channelId,
        'dcSignaling': _config.enableDcSignaling ?? false,
        'av1Support': false,
        'title': ?title,
        'threadID': ?threadId,
      });
      return;
    }
    if (_afterReconnect) return;
    line.sendReconnect(
      channelId: channelId,
      originalId: _sessionId,
      previousId: _resumeId,
    );
    _afterReconnect = true;
    _droppedAt = null;
    _reconnecting = false;
    refreshState();
    _flushLocalCandidates();
    _set(
      (c) => c.copyWith(
        phase: _peerUp ? CallPhase.connected : CallPhase.connecting,
      ),
    );
    _restartAfterNetwork();
  }

  var _networkRestartPending = false;

  void _restartAfterNetwork() {
    if (!_networkRestartPending) return;
    _networkRestartPending = false;
    _trigger(IceTrigger.networkChanged);
  }

  Future<void> _firstOffer() async {
    _set((c) => c.copyWith(phase: CallPhase.connecting));
    _connectTimer = Timer(timings.connectTimeout, () {
      if (!_peerUp) _fail(mediaFailure(mediaPortOf(_serverCandidates)));
    });
    if (!await _negotiate(first: true) && !_over && !_peerUp) {
      Log.warn('calls', 'The server did not answer the first offer');
    }
  }

  // Signalling

  void _onSignal(SignalMessage message) {
    switch (message.kind) {
      case SignalKind.offer:
        unawaited(_onServerOffer(message.sdp));
      case SignalKind.answer:
        final waiting = _answer;
        if (waiting != null && !waiting.isCompleted) waiting.complete(message);
      case SignalKind.candidate:
        if (message.candidate case final candidate?) {
          _serverCandidates.add(candidate.candidate);
          unawaited(_onRemoteCandidate(candidate));
        }
      case SignalKind.unknown:
    }
  }

  Future<void> _onRemoteCandidate(CandidateInit candidate) async {
    final peer = _peer;
    if (peer == null) return;
    if (!_remoteReady) {
      _remoteQueue.add(candidate);
      return;
    }
    try {
      await peer.addCandidate(candidate);
    } on Object catch (e) {
      Log.warn('calls', 'A candidate was refused: ${e.runtimeType}');
    }
  }

  Future<void> _flushRemote() async {
    _remoteReady = true;
    final queued = [..._remoteQueue];
    _remoteQueue.clear();
    for (final candidate in queued) {
      await _onRemoteCandidate(candidate);
    }
  }

  Future<void> _onServerOffer(String sdp) {
    final run = _negotiation.then((_) async {
      final peer = _peer;
      if (_over || peer == null) return;
      try {
        final answer = await peer.answer(sdp);
        await _flushRemote();
        _sendSdp(sessionDescriptionJson('answer', answer));
      } on Object catch (e) {
        Log.warn('calls', 'Answering the server failed: ${e.runtimeType}');
      }
    });
    _negotiation = run.then((_) {}, onError: (Object _) {});
    return run;
  }

  /// Our offer goes over the data channel when the server asked for that
  /// and it is open, else over the socket.
  void _sendSdp(String json) {
    if (_dcOpen && (_config.enableDcSignaling ?? false)) {
      unawaited(_peer?.sendData(encodeDc(DcSdp(json))));
    } else {
      _line?.sendSdp(json);
    }
  }

  Future<bool> _negotiate({bool first = false, bool iceRestart = false}) {
    final run = _negotiation.then(
      (_) => _negotiateNow(first: first, iceRestart: iceRestart),
    );
    _negotiation = run.then((_) {}, onError: (Object _) {});
    return run;
  }

  Future<bool> _negotiateNow({
    required bool first,
    required bool iceRestart,
  }) async {
    final tries = first ? 3 : 2;
    for (var attempt = 0; attempt < tries && !_over; attempt++) {
      final peer = _peer;
      if (peer == null) return false;
      final useLock = !first && _dcOpen;
      if (useLock && !await _takeLock()) continue;
      _remoteReady = false;
      try {
        if (iceRestart) await _refreshTurn(peer);
        final sdp = await peer.createOffer(iceRestart: iceRestart);
        final waiting = _answer = Completer<SignalMessage>();
        _sendSdp(sessionDescriptionJson('offer', sdp));
        final reply = await waiting.future.timeout(timings.answerTimeout);
        await peer.setRemoteAnswer(reply.sdp);
        await _flushRemote();
        return true;
      } on TimeoutException {
        Log.warn('calls', 'No answer to our offer');
        if (!first) await _quietly(peer.rollback);
      } on Object catch (e) {
        Log.warn('calls', 'Negotiating failed: ${e.runtimeType}');
        if (!first) await _quietly(peer.rollback);
      } finally {
        _answer = null;
        if (useLock) unawaited(_peer?.sendData(encodeDc(const DcUnlock())));
      }
    }
    _remoteReady = true;
    return false;
  }

  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (_) {}
  }

  Future<void> _refreshTurn(CallPeer peer) async {
    if (_config.needsTurnCredentials != true) return;
    final turn = await _timed(loadTurn());
    if (turn == null) return;
    _iceServers = _servers(turn);
    await peer.setIceServers(_iceServers);
  }

  /// The signalling lock: asks until the server grants it or the wait is
  /// over.
  Future<bool> _takeLock() async {
    final deadline = clock.now().add(timings.lockWait);
    while (!_over && clock.now().isBefore(deadline)) {
      final reply = _lockReply = Completer<bool>();
      unawaited(_peer?.sendData(encodeDc(const DcLockRequest())));
      final granted = await reply.future.timeout(
        deadline.difference(clock.now()),
        onTimeout: () => false,
      );
      if (granted) return true;
      await Future<void>.delayed(timings.lockRetry);
    }
    return false;
  }

  // Media connection

  void _onPeer(PeerEvent event) {
    if (_over) return;
    switch (event) {
      case PeerLinkChanged(:final link):
        _onLink(link);
      case PeerChannelOpened():
        _dcOpen = true;
        _missed = 0;
        _awaitingPong = false;
        _pingTimer?.cancel();
        _pingTimer = Timer.periodic(timings.pingInterval, (_) => _ping());
      case PeerChannelClosed():
        _dcOpen = false;
        _pingTimer?.cancel();
      case PeerChannelMessage(:final bytes):
        _onData(decodeDc(bytes));
      case PeerCandidate(:final candidate):
        final line = _line;
        if (line == null) {
          _localQueue.add(candidate);
        } else {
          line.send('ice', {'data': candidateJson(candidate)});
        }
    }
  }

  void _flushLocalCandidates() {
    final line = _line;
    if (line == null) return;
    for (final candidate in _localQueue) {
      line.send('ice', {'data': candidateJson(candidate)});
    }
    _localQueue.clear();
  }

  void _onLink(PeerLink link) {
    switch (link) {
      case PeerLink.connected:
        _peerUp = true;
        _connectTimer?.cancel();
        _restartWatch?.cancel();
        _restarts = 0;
        if (_line != null || !_reconnecting) {
          _set((c) => c.copyWith(phase: CallPhase.connected));
        }
        if (!_firstConnected) {
          _firstConnected = true;
          _statsTimer = Timer.periodic(
            const Duration(seconds: 10),
            (_) => unawaited(_logStats()),
          );
          unawaited(_syncRoutes());
        }
        unawaited(_applyMute());
      case PeerLink.disconnected:
        _peerUp = false;
        _trigger(IceTrigger.peerDisconnected);
      case PeerLink.failed:
        _peerUp = false;
        _trigger(IceTrigger.peerFailed);
      case PeerLink.closed:
        _fail(mediaFailure(mediaPortOf(_serverCandidates)));
      case PeerLink.connecting:
    }
  }

  void _onData(DcMessage message) {
    switch (message) {
      case DcPong():
        _awaitingPong = false;
        _missed = 0;
      case DcSdp(:final json):
        if (SignalMessage.parse(json) case final signal?) _onSignal(signal);
      case DcLockReply(:final granted):
        final waiting = _lockReply;
        if (waiting != null && !waiting.isCompleted) waiting.complete(granted);
      case DcPing() ||
          DcLockRequest() ||
          DcUnlock() ||
          DcMediaMap() ||
          DcUnknown():
    }
  }

  void _ping() {
    if (_over || !_dcOpen) return;
    if (_awaitingPong) _missed++;
    if (pongsLost(_missed, timings: timings)) {
      _missed = 0;
      _trigger(IceTrigger.missedPongs);
    }
    _awaitingPong = true;
    unawaited(_peer?.sendData(encodeDc(const DcPing())));
  }

  void _trigger(IceTrigger trigger) {
    final phase = connection.value.phase;
    if (_over ||
        _peer == null ||
        phase == CallPhase.preparing ||
        phase == CallPhase.joining) {
      return;
    }
    final last = _lastRestart;
    switch (iceRestartStep(
      trigger: trigger,
      restarting: _restarting,
      attempts: _restarts,
      sinceLast: last == null ? null : clock.now().difference(last),
      timings: timings,
    )) {
      case IceRestartStep.wait:
        return;
      case IceRestartStep.giveUp:
        _fail(mediaFailure(mediaPortOf(_serverCandidates)));
      case IceRestartStep.restart:
        unawaited(_restartIce());
    }
  }

  Future<void> _restartIce() async {
    _restarting = true;
    _restarts++;
    _lastRestart = clock.now();
    if (!_reconnecting) {
      _set((c) => c.copyWith(phase: CallPhase.restartingIce));
    }
    Log.info('calls', 'Restarting ICE (attempt $_restarts)');
    await _negotiate(iceRestart: true);
    _restarting = false;
    if (_over) return;
    _restartWatch?.cancel();
    _restartWatch = Timer(timings.restartWait, () {
      if (!_peerUp) _trigger(IceTrigger.peerDisconnected);
    });
  }

  void _network() {
    final phase = connection.value.phase;
    if (_over ||
        phase == CallPhase.preparing ||
        phase == CallPhase.joining ||
        _line == null) {
      return;
    }
    // The socket may be dead without knowing it; open a new one, then
    // rebuild the media path on it.
    _networkRestartPending = true;
    final line = _line!;
    _resumeId = line.connectionId;
    _resumeExpected = line.expected;
    _detachLine();
    unawaited(line.close());
    _beginReconnect();
  }

  // The calls socket

  void _onLineClosed(CallLine line) {
    final phase = connection.value.phase;
    _resumeId = line.connectionId;
    _resumeExpected = line.expected;
    _detachLine();
    if (phase == CallPhase.preparing || phase == CallPhase.joining) {
      _fail(
        const CallFailure(
          CallFailureKind.noConnection,
          'The connection to the call server was lost. Try again.',
        ),
      );
      return;
    }
    _beginReconnect();
  }

  void _detachLine() {
    unawaited(_lineSubscription?.cancel());
    _lineSubscription = null;
    _line = null;
  }

  void _beginReconnect() {
    if (_reconnecting || _over) return;
    _reconnecting = true;
    _droppedAt ??= clock.now();
    _afterReconnect = false;
    _set((c) => c.copyWith(phase: CallPhase.reconnecting));
    unawaited(_reconnectLoop());
  }

  Future<void> _reconnectLoop() async {
    while (!_over) {
      final since = clock.now().difference(_droppedAt ?? clock.now());
      final step = reconnectStep(since, timings: timings);
      if (step is! ReconnectIn) {
        _fail(
          const CallFailure(
            CallFailureKind.noConnection,
            'The connection to the call was lost and could not be '
            'restored. Check the connection and join again.',
          ),
        );
        return;
      }
      await Future<void>.delayed(step.delay);
      if (_over) return;
      try {
        final line = await openLine(
          connectionId: _resumeId,
          expected: _resumeExpected,
          originalId: _sessionId,
        );
        if (_over) {
          await line.close();
          return;
        }
        _reconnecting = false;
        _attach(line);
        return;
      } on Object catch (e) {
        Log.info('calls', 'Reconnecting failed: ${e.runtimeType}');
      }
    }
  }

  void _onCallEvent(CallsEvent event) {
    if (event.channelId != channelId) return;
    switch (event) {
      case CallEndedEvent():
        _finish(CallEnd.hostEnded);
      case CallHostRemovedEvent(:final sessionId) when sessionId == _sessionId:
        _finish(CallEnd.removed);
      case CallLeftEvent(:final sessionId) when sessionId == _sessionId:
        _finish(CallEnd.sessionLost);
      case CallHostMuteEvent(:final sessionId) when sessionId == _sessionId:
        unawaited(setMuted(muted: true));
      case CallHostLowerHandEvent(:final sessionId)
          when sessionId == _sessionId:
        _line?.send('unraise_hand');
      default:
    }
  }

  // What the user does

  Future<void> setMuted({required bool muted}) async {
    if (_over || connection.value.listenOnly) return;
    _wantMuted = muted;
    _set((c) => c.copyWith(muted: muted));
    await _applyMute();
  }

  /// Brings the server to the wanted mute state: the audio is switched
  /// first when unmuting, and last when muting, so nobody hears a gap or
  /// an unmuted silence.
  Future<void> _applyMute() async {
    if (_muting) return;
    _muting = true;
    try {
      while (!_over && _serverMuted != _wantMuted) {
        final peer = _peer;
        final line = _line;
        if (peer == null || line == null || !_peerUp) return;
        final muted = _wantMuted;
        if (!muted) await peer.setSending(on: true);
        line.send(muted ? 'mute' : 'unmute');
        if (muted) await peer.setSending(on: false);
        _serverMuted = muted;
      }
    } on Object catch (e) {
      Log.warn('calls', 'Changing the mute state failed: ${e.runtimeType}');
    } finally {
      _muting = false;
    }
  }

  Future<void> setRoute(AudioRoute route) async {
    if (_over) return;
    _pinned = route;
    await _syncRoutes();
  }

  Future<void> _syncRoutes() async {
    if (_over || !_firstConnected) return;
    final routes = await platform.routes();
    if (_over) return;
    _pinned = keepPin(_pinned, routes);
    final chosen = chooseRoute(
      available: routes,
      pinned: _pinned,
      direct: direct,
    );
    final previous = connection.value.route;
    _set((c) => c.copyWith(routes: routes, route: chosen));
    if (chosen != null && chosen != previous) await platform.setRoute(chosen);
  }

  Future<void> _logStats() async {
    final peer = _peer;
    if (_over || peer == null) return;
    try {
      final s = await peer.stats();
      Log.info(
        'calls',
        'Audio sent ${s.sent} B, received ${s.received} B, '
            'level in ${s.receivedLevel} out ${s.sentLevel}',
      );
    } on Object catch (_) {}
  }

  /// The user leaves.
  Future<void> leave() async {
    if (_over) return;
    _line?.send('leave');
    await _finish(CallEnd.left);
  }

  Future<void> _finish(CallEnd reason) => _close(
    (c) => c.copyWith(phase: CallPhase.ended, endedBy: reason, failure: null),
  );

  void _fail(CallFailure failure) {
    unawaited(
      _close((c) => c.copyWith(phase: CallPhase.failed, failure: failure)),
    );
  }

  Future<void> _close(CallConnection Function(CallConnection) end) async {
    if (_over) return;
    _finished = true;
    for (final timer in [
      _joinTimer,
      _connectTimer,
      _restartWatch,
      _pingTimer,
      _statsTimer,
    ]) {
      timer?.cancel();
    }
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
    unawaited(_lineSubscription?.cancel());
    _lineSubscription = null;
    final line = _line;
    final peer = _peer;
    _line = null;
    _peer = null;
    _set(end);
    await _quietly(() async => line?.close());
    await _quietly(() async => peer?.close());
    await _quietly(platform.stopService);
  }

  Future<void> dispose() async {
    await _close((c) => c.copyWith(phase: CallPhase.ended));
    connection.dispose();
  }
}

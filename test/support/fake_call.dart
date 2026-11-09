import 'dart:async';
import 'dart:typed_data';

import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/data/calls/call_session.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_rules.dart';

/// A calls socket the test drives: [emit] events in, [sent] actions out.
class FakeLine implements CallLine {
  FakeLine(this._log, {required this.connectionId, this.expected = 0});

  final List<String> _log;
  final _events = StreamController<LineEvent>.broadcast(sync: true);
  final sent = <({String action, Map<String, Object?>? data})>[];
  final sdp = <String>[];
  var reconnects = <Map<String, String>>[];
  var closed = false;

  @override
  final String connectionId;
  @override
  final int expected;

  @override
  Stream<LineEvent> get events => _events.stream;

  void emit(LineEvent event) => _events.add(event);

  /// The socket drops.
  void drop() {
    emit(const LineClosed());
    unawaited(_events.close());
  }

  List<String> get actions => [for (final s in sent) s.action];

  @override
  void send(String action, [Map<String, Object?>? data]) {
    sent.add((action: action, data: data));
    _log.add('line:$action');
  }

  @override
  void sendSdp(String json) {
    sdp.add(json);
    _log.add('line:sdp');
  }

  @override
  void sendReconnect({
    required String channelId,
    required String originalId,
    required String previousId,
  }) {
    if (reconnects.isNotEmpty) return;
    reconnects.add({
      'channelId': channelId,
      'originalId': originalId,
      'previousId': previousId,
    });
    _log.add('line:reconnect');
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}

/// A media connection the test drives. The server's side is played by the
/// test through [emit].
class FakePeer implements CallPeer {
  FakePeer(this._log);

  final List<String> _log;
  final _events = StreamController<PeerEvent>.broadcast(sync: true);
  final data = <DcMessage>[];
  final offers = <({bool iceRestart})>[];
  final remoteAnswers = <String>[];
  final candidates = <CandidateInit>[];
  var started = false;
  bool? microphone;
  var closed = false;
  var rollbacks = 0;
  Object? startError;

  @override
  Stream<PeerEvent> get events => _events.stream;

  void emit(PeerEvent event) => _events.add(event);

  void link(PeerLink link) => emit(PeerLinkChanged(link));

  @override
  Future<void> start({
    required List<IceServer> iceServers,
    required bool microphone,
  }) async {
    final error = startError;
    if (error != null && microphone) throw error;
    started = true;
    this.microphone = microphone;
    _log.add('peer:start');
  }

  @override
  Future<String> createOffer({bool iceRestart = false}) async {
    offers.add((iceRestart: iceRestart));
    _log.add('peer:offer');
    return 'offer-${offers.length}';
  }

  @override
  Future<void> setRemoteAnswer(String sdp) async => remoteAnswers.add(sdp);

  @override
  Future<String> answer(String offerSdp) async => 'answer-to-$offerSdp';

  @override
  Future<void> rollback() async => rollbacks++;

  @override
  Future<void> addCandidate(CandidateInit candidate) async =>
      candidates.add(candidate);

  @override
  Future<void> setIceServers(List<IceServer> iceServers) async {}

  @override
  Future<void> setSending({required bool on}) async =>
      _log.add('peer:sending:$on');

  @override
  Future<void> sendData(Uint8List bytes) async => data.add(decodeDc(bytes));

  @override
  Future<AudioStats> stats() async =>
      (sent: 0, received: 0, receivedLevel: null, sentLevel: null);

  @override
  Future<void> close() async => closed = true;
}

class FakeCallPlatform implements CallPlatform {
  var microphone = true;
  var serviceRunning = false;
  var routeList = <AudioRoute>[AudioRoute.earpiece, AudioRoute.speaker];
  final appliedRoutes = <AudioRoute>[];
  final hangUp = StreamController<void>.broadcast(sync: true);
  final routesChange = StreamController<void>.broadcast(sync: true);

  Future<void> close() async {
    await hangUp.close();
    await routesChange.close();
  }

  @override
  Future<bool> requestMicrophone() async => microphone;

  @override
  Future<void> startService({
    required String title,
    required String text,
  }) async => serviceRunning = true;

  @override
  Future<void> stopService() async => serviceRunning = false;

  @override
  Stream<void> get hangUps => hangUp.stream;

  @override
  Future<void> prepareAudio() async {}

  @override
  Future<List<AudioRoute>> routes() async => routeList;

  @override
  Stream<void> get routesChanged => routesChange.stream;

  @override
  Future<void> setRoute(AudioRoute route) async => appliedRoutes.add(route);
}

/// A call session wired to fakes. [log] shows the order of what went to the
/// server and to the media connection.
class CallHarness {
  CallHarness({
    bool dcSignaling = false,
    bool direct = true,
    this.micFails = false,
    this.timings = const CallTimings(),
  }) : config = CallsConfig(enableDcSignaling: dcSignaling) {
    session = CallSession(
      channelId: channel,
      direct: direct,
      timings: timings,
      platform: platform,
      createPeer: () {
        final peer = FakePeer(log);
        if (micFails) peer.startError = StateError('no microphone');
        peers.add(peer);
        return peer;
      },
      openLine:
          ({
            required connectionId,
            required expected,
            required originalId,
          }) async {
            opens.add((connectionId: connectionId, originalId: originalId));
            if (failOpens > 0) {
              failOpens--;
              throw StateError('no connection');
            }
            final line = FakeLine(
              log,
              connectionId: 'conn${lines.length + 1}',
              expected: 5,
            );
            lines.add(line);
            return line;
          },
      loadConfig: () async => config,
      loadTurn: () async => const [],
      refreshState: () => refreshes++,
      failureText: (error) => 'failed: $error',
      networkChanges: network.stream,
    );
  }

  static const channel = 'ch000000000000000000000001';

  final CallTimings timings;
  final bool micFails;
  final CallsConfig config;
  final log = <String>[];
  final lines = <FakeLine>[];
  final peers = <FakePeer>[];
  final opens = <({String connectionId, String originalId})>[];
  final platform = FakeCallPlatform();
  final network = StreamController<void>.broadcast(sync: true);
  late final CallSession session;
  var failOpens = 0;
  var refreshes = 0;

  Future<void> close() async {
    await network.close();
    await platform.close();
  }

  FakeLine get line => lines.last;
  FakePeer get peer => peers.last;
  CallConnection get state => session.connection.value;

  /// Joins up to the point where the first offer is out.
  void join(void Function() flush) {
    unawaited(session.start());
    flush();
    line.emit(const LineHello('conn1'));
    flush();
    line.emit(const LineJoined());
    flush();
  }

  /// The server answers our offer and the media connects.
  void connect(void Function() flush) {
    line.emit(LineSignal(sessionDescriptionJson('answer', 'server-answer')));
    flush();
    peer
      ..emit(const PeerChannelOpened())
      ..link(PeerLink.connected);
    flush();
  }
}

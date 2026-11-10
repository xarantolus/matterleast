import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/log.dart';

/// A STUN or TURN server; one URL per entry is what every platform reads.
typedef IceServer = ({List<String> urls, String? username, String? credential});

enum PeerLink { connecting, connected, disconnected, failed, closed }

/// What the peer connection tells the call.
sealed class PeerEvent {
  const PeerEvent();
}

final class PeerLinkChanged extends PeerEvent {
  const PeerLinkChanged(this.link);
  final PeerLink link;
}

final class PeerChannelOpened extends PeerEvent {
  const PeerChannelOpened();
}

final class PeerChannelClosed extends PeerEvent {
  const PeerChannelClosed();
}

final class PeerChannelMessage extends PeerEvent {
  const PeerChannelMessage(this.bytes);
  final Uint8List bytes;
}

final class PeerCandidate extends PeerEvent {
  const PeerCandidate(this.candidate);
  final CandidateInit candidate;
}

/// Bytes and loudness of the audio, for the log.
typedef AudioStats = ({
  int sent,
  int received,
  double? receivedLevel,
  double? sentLevel,
});

/// The media connection to the call server: audio, and the `calls-dc` data
/// channel. Behind an interface so the call logic runs without WebRTC.
abstract interface class CallPeer {
  Stream<PeerEvent> get events;

  /// Creates the connection with the data channel and an audio transceiver,
  /// and puts the microphone on it (disabled) when [microphone] is true.
  /// Throws when the microphone can't be opened.
  Future<void> start({
    required List<IceServer> iceServers,
    required bool microphone,
  });

  /// Our offer; [iceRestart] asks for new ICE credentials. Returns its SDP
  /// once it is set as the local description.
  Future<String> createOffer({bool iceRestart = false});

  Future<void> setRemoteAnswer(String sdp);

  /// Takes the server's offer and returns our answer.
  Future<String> answer(String offerSdp);

  /// Drops our unanswered offer.
  Future<void> rollback();
  Future<void> addCandidate(CandidateInit candidate);
  Future<void> setIceServers(List<IceServer> iceServers);

  /// Lets the microphone's audio through, or silences it, without any
  /// renegotiation.
  Future<void> setSending({required bool on});
  Future<void> sendData(Uint8List bytes);
  Future<AudioStats> stats();
  Future<void> close();
}

typedef CallPeerFactory = CallPeer Function();

/// The `ufrag` a candidate line names, which a restart changes.
String? ufragOf(String candidate) {
  final parts = candidate.split(' ');
  final at = parts.indexOf('ufrag');
  return at >= 0 && at + 1 < parts.length ? parts[at + 1] : null;
}

/// The constraints of our offer. flutter_webrtc reads only `mandatory` and
/// `optional`; a restart named anywhere else is silently a plain offer that
/// keeps the old credentials and ports.
Map<String, Object> offerConstraints({required bool iceRestart}) => {
  if (iceRestart) 'mandatory': {'IceRestart': true},
};

/// [CallPeer] on flutter_webrtc.
class WebRtcPeer implements CallPeer {
  final _events = StreamController<PeerEvent>.broadcast();
  RTCPeerConnection? _pc;
  RTCDataChannel? _channel;
  RTCRtpSender? _sender;
  MediaStream? _microphone;
  MediaStreamTrack? _track;

  @override
  Stream<PeerEvent> get events => _events.stream;

  RTCPeerConnection get _connection {
    final pc = _pc;
    if (pc == null) throw StateError('The peer connection is closed');
    return pc;
  }

  @override
  Future<void> start({
    required List<IceServer> iceServers,
    required bool microphone,
  }) async {
    if (microphone) {
      _microphone = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      final track = _microphone!.getAudioTracks().firstOrNull;
      if (track == null) throw StateError('No audio track');
      track.enabled = false;
      _track = track;
    }
    final pc = await createPeerConnection({
      'iceServers': _servers(iceServers),
      'sdpSemantics': 'unified-plan',
    });
    _pc = pc;
    pc.onConnectionState = (state) => _emit(PeerLinkChanged(_link(state)));
    pc.onIceCandidate = (c) {
      final text = c.candidate;
      if (text == null || text.isEmpty) return;
      _emit(
        PeerCandidate(
          CandidateInit(
            candidate: text,
            sdpMid: c.sdpMid,
            sdpMLineIndex: c.sdpMLineIndex,
            usernameFragment: ufragOf(text),
          ),
        ),
      );
    };
    final channel = await pc.createDataChannel(
      'calls-dc',
      RTCDataChannelInit()..binaryType = 'binary',
    );
    _channel = channel;
    channel.onDataChannelState = (state) => switch (state) {
      RTCDataChannelState.RTCDataChannelOpen => _emit(
        const PeerChannelOpened(),
      ),
      RTCDataChannelState.RTCDataChannelClosed => _emit(
        const PeerChannelClosed(),
      ),
      _ => null,
    };
    channel.onMessage = (message) {
      if (message.isBinary) _emit(PeerChannelMessage(message.binary));
    };
    final transceiver = await pc.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    );
    _sender = transceiver.sender;
    final track = _track;
    if (track != null) await _sender!.replaceTrack(track);
  }

  void _emit(PeerEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  static PeerLink _link(RTCPeerConnectionState state) => switch (state) {
    RTCPeerConnectionState.RTCPeerConnectionStateConnected =>
      PeerLink.connected,
    RTCPeerConnectionState.RTCPeerConnectionStateDisconnected =>
      PeerLink.disconnected,
    RTCPeerConnectionState.RTCPeerConnectionStateFailed => PeerLink.failed,
    RTCPeerConnectionState.RTCPeerConnectionStateClosed => PeerLink.closed,
    _ => PeerLink.connecting,
  };

  static List<Map<String, Object?>> _servers(List<IceServer> servers) => [
    for (final s in servers)
      for (final url in s.urls)
        {
          'urls': url,
          if (s.username != null) 'username': s.username,
          if (s.credential != null) 'credential': s.credential,
        },
  ];

  @override
  Future<String> createOffer({bool iceRestart = false}) async {
    final pc = _connection;
    final offer = await pc.createOffer(
      offerConstraints(iceRestart: iceRestart),
    );
    await pc.setLocalDescription(offer);
    return offer.sdp ?? '';
  }

  @override
  Future<void> setRemoteAnswer(String sdp) =>
      _connection.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));

  @override
  Future<String> answer(String offerSdp) async {
    final pc = _connection;
    if (pc.signalingState ==
        RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      await rollback();
    }
    await pc.setRemoteDescription(RTCSessionDescription(offerSdp, 'offer'));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    return answer.sdp ?? '';
  }

  @override
  Future<void> rollback() =>
      // An empty text, not null: a null one aborts the app inside libwebrtc.
      _connection.setLocalDescription(RTCSessionDescription('', 'rollback'));

  @override
  Future<void> addCandidate(CandidateInit c) => _connection.addCandidate(
    RTCIceCandidate(c.candidate, c.sdpMid, c.sdpMLineIndex),
  );

  @override
  Future<void> setIceServers(List<IceServer> iceServers) =>
      _connection.setConfiguration({
        'iceServers': _servers(iceServers),
        'sdpSemantics': 'unified-plan',
      });

  @override
  Future<void> setSending({required bool on}) async {
    final track = _track;
    if (track == null) return;
    track.enabled = on;
  }

  @override
  Future<void> sendData(Uint8List bytes) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.send(RTCDataChannelMessage.fromBinary(bytes));
  }

  @override
  Future<AudioStats> stats() async {
    var sent = 0;
    var received = 0;
    double? receivedLevel;
    double? sentLevel;
    for (final report in await _connection.getStats()) {
      final v = report.values;
      if (v['kind'] != 'audio' && v['mediaType'] != 'audio') continue;
      final bytes = v['bytesSent'] ?? v['bytesReceived'];
      final level = v['audioLevel'];
      switch (report.type) {
        case 'outbound-rtp':
          if (bytes is num) sent += bytes.toInt();
        case 'inbound-rtp':
          if (bytes is num) received += bytes.toInt();
          if (level is num) receivedLevel = level.toDouble();
        case 'media-source':
          if (level is num) sentLevel = level.toDouble();
      }
    }
    return (
      sent: sent,
      received: received,
      receivedLevel: receivedLevel,
      sentLevel: sentLevel,
    );
  }

  @override
  Future<void> close() async {
    final pc = _pc;
    _pc = null;
    // Each step on its own: one that throws (on Windows a stopped track
    // can fail the next call) must not leave the connection open.
    Future<void> step(Future<void>? Function() run) async {
      try {
        await run();
      } on Object catch (e) {
        Log.warn('calls', 'Closing the peer failed', e);
      }
    }

    await step(() => _channel?.close());
    await step(() => _track?.stop());
    await step(() => _microphone?.dispose());
    await step(() => pc?.close());
    await step(() => pc?.dispose());
    await _events.close();
  }
}

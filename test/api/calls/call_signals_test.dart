import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/api/calls/msgpack.dart';

Uint8List _bytes(List<int> b) => Uint8List.fromList(b);

void main() {
  group('the socket SDP frame', () {
    test('is a MessagePack map whose data is the zlib-compressed JSON', () {
      const json = '{"type":"offer","sdp":"v=0\\r\\n"}';
      final map = PackReader(sdpSocketFrame(7, json)).read()!
          as Map<String, Object?>;
      expect(map['action'], 'custom_com.mattermost.calls_sdp');
      expect(map['seq'], 7);
      final data = map['data']! as Map<String, Object?>;
      expect(inflateSdp(data['data']! as Uint8List), json);
    });

    test('carries a long description with a wide binary header', () {
      final json = jsonEncode({
        'type': 'offer',
        'sdp': List.generate(4000, (i) => 'a=line$i${i * 7919}').join('\r\n'),
      });
      final frame = PackReader(sdpSocketFrame(300, json)).read()!
          as Map<String, Object?>;
      expect(frame['seq'], 300);
      final data = frame['data']! as Map<String, Object?>;
      expect(inflateSdp(data['data']! as Uint8List), json);
    });
  });

  group('data channel messages', () {
    test('what we send round-trips', () {
      expect(decodeDc(encodeDc(const DcPing())), isA<DcPing>());
      expect(decodeDc(encodeDc(const DcUnlock())), isA<DcUnlock>());
      expect(decodeDc(encodeDc(const DcLockRequest())), isA<DcLockRequest>());
      final sdp = decodeDc(encodeDc(const DcSdp('{"type":"offer"}')));
      expect((sdp as DcSdp).json, '{"type":"offer"}');
    });

    test('we send the one-byte type', () {
      expect(encodeDc(const DcPing()), [1]);
      expect(encodeDc(const DcLockRequest()), [7]);
      expect(encodeDc(const DcUnlock()), [8]);
    });

    test('the server sends the two-byte type, which reads the same', () {
      expect(decodeDc(_bytes([0xcc, 0x02])), isA<DcPong>());
      expect(
        (decodeDc(_bytes([0xcc, 0x07, 0xc3])) as DcLockReply).granted,
        isTrue,
      );
      expect(
        (decodeDc(_bytes([0xcc, 0x07, 0xc2])) as DcLockReply).granted,
        isFalse,
      );
      expect(decodeDc(_bytes([0x02])), isA<DcPong>());
    });

    test('a server SDP is inflated', () {
      final w = PackWriter()
        ..writeUint(3)
        ..writeBin(compressSdp('{"type":"answer","sdp":"x"}'));
      final message = decodeDc(w.takeBytes());
      expect((message as DcSdp).json, '{"type":"answer","sdp":"x"}');
    });

    test('the media map keeps the kind of each mid', () {
      final w = PackWriter()
        ..writeUint(9)
        ..writeMapHeader(2)
        ..writeString('0')
        ..writeMapHeader(2)
        ..writeString('type')
        ..writeString('voice')
        ..writeString('sender_id')
        ..writeString('s1')
        ..writeString('2')
        ..writeMapHeader(1)
        ..writeString('type')
        ..writeString('screen');
      final map = decodeDc(w.takeBytes()) as DcMediaMap;
      expect(map.kinds, {'0': 'voice', '2': 'screen'});
    });

    test('garbage is unknown, not an error', () {
      expect(decodeDc(_bytes([])), isA<DcUnknown>());
      expect(decodeDc(_bytes([0xcc])), isA<DcUnknown>());
      expect(decodeDc(_bytes([3, 0xc4, 2, 1, 2])), isA<DcUnknown>());
      expect(decodeDc(_bytes([0x63])), isA<DcUnknown>());
    });
  });

  group('signals', () {
    test('an offer, an answer and a candidate read', () {
      final offer = SignalMessage.parse('{"type":"offer","sdp":"v=0"}')!;
      expect(offer.kind, SignalKind.offer);
      expect(offer.sdp, 'v=0');
      final candidate = SignalMessage.parse(
        '{"type":"candidate","candidate":{"candidate":"candidate:1 1 udp",'
        '"sdpMid":"0","sdpMLineIndex":0,"usernameFragment":"u"}}',
      )!;
      expect(candidate.kind, SignalKind.candidate);
      expect(candidate.candidate!.sdpMid, '0');
      expect(candidate.candidate!.usernameFragment, 'u');
    });

    test('something else is ignored', () {
      expect(SignalMessage.parse('nope'), isNull);
      expect(SignalMessage.parse(5), isNull);
      expect(SignalMessage.parse('{"type":"hello"}')!.kind, SignalKind.unknown);
    });

    test('a candidate is sent as the plugin names its fields', () {
      const c = CandidateInit(candidate: 'candidate:1', sdpMid: '0');
      expect(jsonDecode(candidateJson(c)), {
        'candidate': 'candidate:1',
        'sdpMid': '0',
      });
    });
  });
}

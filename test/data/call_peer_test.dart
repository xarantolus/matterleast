import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/calls/call_peer.dart';

void main() {
  group('the offer constraints', () {
    test('ask for new ICE credentials where flutter_webrtc reads them', () {
      final constraints = offerConstraints(iceRestart: true);
      expect(constraints.keys, ['mandatory']);
      expect(constraints['mandatory'], {'IceRestart': true});
    });

    test('ask for nothing extra for a plain offer', () {
      expect(offerConstraints(iceRestart: false), isEmpty);
    });
  });
}

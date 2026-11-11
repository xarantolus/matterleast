import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';

void main() {
  group('which transport a plugin version uses', () {
    test('2.0.0 and later use LiveKit, with or without a suffix', () {
      for (final v in ['2.0.0', '2.0.1-dev', 'v2.3.1', '3.0.0']) {
        expect(callsUseLiveKit(v), isTrue, reason: v);
      }
    });

    test('1.x, nothing and nonsense use the classic transport', () {
      for (final v in ['1.12.5', '1.99.0', '', 'dev', null]) {
        expect(callsUseLiveKit(v), isFalse, reason: '$v');
      }
    });
  });

  test('an identity names the user and the session', () {
    expect(parseCallIdentity('u1___s1'), (userId: 'u1', sessionId: 's1'));
    expect(parseCallIdentity('odd'), (userId: '', sessionId: 'odd'));
  });

  test('speaking changes are the difference of two sets', () {
    final change = speakingChanges({'a', 'b'}, {'b', 'c'});
    expect(change.started, {'c'});
    expect(change.stopped, {'a'});
  });
}

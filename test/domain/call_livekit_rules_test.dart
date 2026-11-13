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

  test('the room address may be unencrypted only on a plain http server', () {
    const secure = 'https://chat.test';
    const plain = 'http://10.0.2.2:8165';
    for (final (room, server, ok) in [
      ('wss://media.test', secure, true),
      ('https://media.test', secure, true),
      ('WSS://media.test', secure, true),
      ('ws://media.test', secure, false),
      ('http://media.test', secure, false),
      ('ws://10.0.2.2:7880', plain, true),
      ('http://10.0.2.2:7880', plain, true),
      ('wss://media.test', plain, true),
      ('evil wss://media.test', secure, false),
      ('ftp://media.test', plain, false),
      ('wss://', secure, false),
      ('', plain, false),
    ]) {
      expect(liveKitUrlAllowed(room, server), ok, reason: '$room on $server');
    }
  });

  test('only the user the server named is the bot', () {
    expect(isCallBot('robot___s1', 'robot'), isTrue);
    expect(isCallBot('bob___s1', 'robot'), isFalse);
    expect(isCallBot('robot___s1', ''), isFalse);
  });

  test('a peer reaction needs a name or a character, within the caps', () {
    expect(acceptedReaction(name: 'tada'), 'tada');
    expect(acceptedReaction(literal: '🎉'), '🎉');
    expect(acceptedReaction(name: '', literal: '🎉'), '🎉');
    expect(acceptedReaction(), isNull);
    expect(acceptedReaction(name: 'a' * 129), isNull);
    expect(acceptedReaction(name: 'a' * 128), 'a' * 128);
    expect(acceptedReaction(name: 'x', literal: 'a' * 33), isNull);
  });

  test('speaking changes are the difference of two sets', () {
    final change = speakingChanges({'a', 'b'}, {'b', 'c'});
    expect(change.started, {'c'});
    expect(change.stopped, {'a'});
  });
}

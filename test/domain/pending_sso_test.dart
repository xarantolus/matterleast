import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/servers/browser_auth_session.dart';
import 'package:matterleast/domain/pending_sso.dart';
import 'package:matterleast/domain/sso_callback.dart';

void main() {
  final started = DateTime.utc(2026, 11, 6, 12);
  final pending = PendingSso(
    serverUrl: 'https://chat.example.test',
    displayName: 'Team Chat',
    state: 'state',
    verifier: 'verifier',
    startedAt: started,
  );

  test('a callback counts until the browser sign-in times out', () {
    expect(pending.isFresh(started, browserSignInTimeout), isTrue);
    expect(
      pending.isFresh(
        started.add(browserSignInTimeout - const Duration(seconds: 1)),
        browserSignInTimeout,
      ),
      isTrue,
    );
    expect(
      pending.isFresh(started.add(browserSignInTimeout), browserSignInTimeout),
      isFalse,
    );
  });

  test('a clock set back past the start does not keep it alive', () {
    expect(
      pending.isFresh(
        started.subtract(const Duration(hours: 1)),
        browserSignInTimeout,
      ),
      isFalse,
    );
  });

  test('it survives storage and rebuilds the challenge it started with', () {
    final challenge = SsoChallenge.generate();
    final saved = PendingSso(
      serverUrl: 'https://chat.example.test',
      displayName: 'Team Chat',
      ssoScheme: 'other',
      replaces: 'https://old.example.test',
      state: challenge.state,
      verifier: challenge.verifier,
      startedAt: started,
    );
    final back = PendingSso.fromJson(saved.toJson());
    expect(back, saved);
    expect(back.challenge.challenge, challenge.challenge);
    expect(back.scheme, 'other');
    expect(pending.scheme, defaultSsoScheme);
  });
}

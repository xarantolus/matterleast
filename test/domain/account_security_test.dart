import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/account_security.dart';

void main() {
  group('terms due', () {
    const cases = <(String?, String?, bool)>[
      (null, null, false),
      ('', 'old', false),
      ('v2', null, true),
      ('v2', '', true),
      ('v2', 'v1', true),
      ('v2', 'v2', false),
    ];
    for (final (termsId, accepted, due) in cases) {
      test('server asks for $termsId, user accepted $accepted: $due', () {
        expect(termsDue(termsId: termsId, acceptedId: accepted), due);
      });
    }
  });

  group('two-factor setup', () {
    const cases = <(bool, String, bool)>[
      (true, '', true),
      (true, 'gitlab', false),
      (true, 'saml', false),
      (false, '', false),
      (false, 'gitlab', false),
    ];
    for (final (offers, service, manageable) in cases) {
      test('server offers $offers, account via "$service": $manageable', () {
        expect(
          mfaManageable(serverOffers: offers, authService: service),
          manageable,
        );
      });
    }
  });

  group('current session', () {
    final now = DateTime.utc(2026, 11, 2, 12);
    String? current(List<(String, DateTime?)> rows) => currentSessionId([
      for (final (id, at) in rows) (id: id, lastActive: at),
    ]);

    test('the most recently active one asks', () {
      expect(
        current([
          ('a', now.subtract(const Duration(hours: 3))),
          ('b', now),
          ('c', now.subtract(const Duration(days: 2))),
        ]),
        'b',
      );
    });

    test('a lone session is the current one', () {
      expect(current([('a', now)]), 'a');
    });

    test('two about equally recent leave it open', () {
      expect(
        current([('a', now), ('b', now.subtract(const Duration(seconds: 2)))]),
        isNull,
      );
    });

    test('no activity times, no answer', () {
      expect(current([('a', null)]), isNull);
      expect(current([]), isNull);
    });
  });

  test('device names use what the server recorded', () {
    expect(
      sessionDeviceName(
        platform: 'Linux',
        os: 'Android',
        browser: 'Matterleast',
      ),
      'Matterleast on Android',
    );
    expect(sessionDeviceName(platform: 'Windows'), 'Windows');
    expect(sessionDeviceName(browser: 'Chrome', os: 'unknown'), 'Chrome');
    expect(sessionDeviceName(), 'Unknown device');
    expect(
      sessionDeviceName(browser: 'Unknown/0.0', platform: 'Unknown', os: ''),
      'Unknown device',
    );
  });

  group('activity label by calendar date', () {
    // Local times, so the test holds in any time zone.
    final now = DateTime(2026, 11, 2, 0, 10);
    test('today, yesterday across midnight, unknown', () {
      expect(
        sessionActivityLabel(DateTime(2026, 11, 2, 0, 5), now, use24: true),
        'Last active 00:05',
      );
      expect(
        sessionActivityLabel(DateTime(2026, 11, 1, 23, 55), now, use24: true),
        'Last active yesterday at 23:55',
      );
      expect(sessionActivityLabel(null, now, use24: true), contains('unknown'));
    });
  });
}

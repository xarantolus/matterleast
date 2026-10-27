import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/app_update.dart';

void main() {
  group('versions', () {
    int compare(String a, String b) =>
        compareVersions(parseVersion(a)!, parseVersion(b)!).sign;

    test('compare part by part as numbers', () {
      expect(compare('v0.12.0', '0.11.1'), 1);
      expect(compare('0.10.0', '0.9.9'), 1);
      expect(compare('v0.11.1', '0.11.1'), 0);
      expect(compare('0.11.0', '0.11.1'), -1);
      expect(compare('1.0.0', '0.99.99'), 1);
    });

    test('ignore the build number', () {
      expect(compare('0.11.1+18', 'v0.11.1'), 0);
    });

    test('anything else does not parse', () {
      expect(parseVersion('v0.12.0-beta.1'), isNull);
      expect(parseVersion('0.12'), isNull);
      expect(parseVersion('latest'), isNull);
      expect(parseVersion(''), isNull);
    });
  });

  group('the update shown', () {
    const next = KnownRelease(
      tag: 'v0.12.0',
      url: 'https://github.com/owner/app/releases/tag/v0.12.0',
    );

    KnownRelease? shown(
      String running, {
      KnownRelease? latest = next,
      String? dismissed,
    }) => updateToShow(running: running, latest: latest, dismissed: dismissed);

    test('is a newer release', () {
      expect(shown('0.11.1'), next);
      expect(shown('0.9.0'), next);
    });

    test('is nothing for the same, an older or no release', () {
      expect(shown('0.12.0'), isNull);
      expect(shown('0.13.0'), isNull);
      expect(shown('0.11.1', latest: null), isNull);
    });

    test('is nothing for a tag that does not parse', () {
      expect(shown('0.11.1', latest: next.copyWith(tag: 'nightly')), isNull);
    });

    test('stays hidden for the dismissed version until a newer one', () {
      expect(shown('0.11.1', dismissed: 'v0.12.0'), isNull);
      expect(shown('0.11.1', dismissed: 'v0.11.5'), next);
      expect(
        shown(
          '0.11.1',
          latest: next.copyWith(tag: 'v0.12.1'),
          dismissed: 'v0.12.0',
        ),
        isNotNull,
      );
    });

    test('labels the version without its v', () {
      expect(versionLabel('v0.12.0'), '0.12.0');
      expect(versionLabel('0.12.0'), '0.12.0');
    });
  });

  group('a check', () {
    final last = DateTime.utc(2026, 10, 27, 9);

    test('is due without an earlier one', () {
      expect(updateCheckDue(null, last), isTrue);
    });

    test('waits a day after the last one', () {
      expect(
        updateCheckDue(last, last.add(const Duration(hours: 23))),
        isFalse,
      );
      expect(updateCheckDue(last, last.add(const Duration(days: 1))), isTrue);
    });

    test('is due when the clock went back', () {
      expect(
        updateCheckDue(last, last.subtract(const Duration(minutes: 1))),
        isTrue,
      );
    });
  });
}

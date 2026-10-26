import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/user_profile.dart';

Map<String, Object?> props(Map<String, Object?> status) => {
  'customStatus': jsonEncode(status),
};

void main() {
  final now = DateTime.utc(2026, 5, 4, 12);

  group('a custom status', () {
    test('shows with its emoji and text', () {
      final status = customStatusOf(
        props({'emoji': 'palm_tree', 'text': 'Away until Monday'}),
        now,
      );
      expect(status?.emoji, 'palm_tree');
      expect(status?.text, 'Away until Monday');
    });

    test('is gone once it has expired', () {
      final status = props({
        'emoji': 'calendar',
        'text': 'In a meeting',
        'duration': 'one_hour',
        'expires_at': '2026-05-04T11:59:00Z',
      });
      expect(customStatusOf(status, now), isNull);
      expect(
        customStatusOf(status, DateTime.utc(2026, 5, 4, 11, 30)),
        isNotNull,
      );
    });

    test("that doesn't clear ignores a leftover expiry", () {
      final status = props({
        'emoji': 'house',
        'text': 'Working from home',
        'duration': '',
        'expires_at': '2020-01-01T00:00:00Z',
      });
      expect(customStatusOf(status, now), isNotNull);
    });

    test('is nothing when empty or malformed', () {
      expect(customStatusOf(null, now), isNull);
      expect(customStatusOf({'customStatus': ''}, now), isNull);
      expect(customStatusOf({'customStatus': '{not json'}, now), isNull);
      expect(customStatusOf(props({'emoji': '', 'text': ''}), now), isNull);
    });

    test('round-trips through the JSON the server keeps', () {
      final status = CustomStatus(
        emoji: 'hamburger',
        text: 'Out for lunch',
        duration: 'thirty_minutes',
        expiresAt: DateTime.utc(2026, 5, 4, 12, 30),
      );
      expect(
        customStatusOf({'customStatus': jsonEncode(status.toJson())}, now),
        status,
      );
    });
  });

  group('a custom status set now clears', () {
    final monday = DateTime(2026, 5, 4, 15, 10);

    test('after its preset time', () {
      expect(
        customStatusExpiry('thirty_minutes', monday),
        DateTime(2026, 5, 4, 15, 40),
      );
      expect(
        customStatusExpiry('four_hours', monday),
        DateTime(2026, 5, 4, 19, 10),
      );
    });

    test('at the end of today and the end of Sunday for this week', () {
      expect(
        customStatusExpiry('today', monday),
        DateTime(2026, 5, 4, 23, 59, 59, 999),
      );
      expect(
        customStatusExpiry('this_week', monday),
        DateTime(2026, 5, 10, 23, 59, 59, 999),
      );
      expect(
        customStatusExpiry('this_week', DateTime(2026, 5, 10, 9)),
        DateTime(2026, 5, 10, 23, 59, 59, 999),
      );
    });

    test('never when it should not clear', () {
      expect(customStatusExpiry('', monday), isNull);
    });

    test('at the moment the user chose, which must still be ahead', () {
      final friday = DateTime(2026, 5, 8, 17, 30);
      expect(
        customStatusExpiry(customStatusDateAndTime, monday, chosen: friday),
        friday,
      );
      expect(customStatusEndValid(friday, monday), isTrue);
      expect(customStatusEndValid(DateTime(2026, 5, 4, 15), monday), isFalse);
      expect(customStatusEndValid(null, monday), isFalse);
    });
  });

  test('do not disturb ends after its length, or tomorrow at nine', () {
    final evening = DateTime(2026, 5, 4, 22, 40);
    expect(dndEnd(DndLength.untilChanged, evening), isNull);
    expect(dndEnd(DndLength.oneHour, evening), DateTime(2026, 5, 4, 23, 40));
    expect(dndEnd(DndLength.twoHours, evening), DateTime(2026, 5, 5, 0, 40));
    expect(dndEnd(DndLength.tomorrow, evening), DateTime(2026, 5, 5, 9));
  });

  test('the timezone is the manual one only when automatic is off', () {
    expect(
      timezoneName(
        useAutomatic: 'true',
        automatic: 'Europe/Lisbon',
        manual: 'Asia/Tokyo',
      ),
      'Europe/Lisbon',
    );
    expect(
      timezoneName(
        useAutomatic: 'false',
        automatic: 'Europe/Lisbon',
        manual: 'Asia/Tokyo',
      ),
      'Asia/Tokyo',
    );
    expect(timezoneName(useAutomatic: 'true', automatic: ''), isNull);
  });

  test('recent custom statuses are listed newest first, odd entries left '
      'out', () {
    final json = jsonEncode([
      {'emoji': 'sailboat', 'text': 'At sea', 'duration': 'today'},
      {'emoji': 'coffee', 'text': 'Brewing', 'duration': ''},
      {'emoji': '', 'text': ''},
      'not a status',
    ]);
    expect(recentCustomStatuses(json).map((s) => s.text), [
      'At sea',
      'Brewing',
    ]);
    expect(recentCustomStatuses(null), isEmpty);
    expect(recentCustomStatuses('{oops'), isEmpty);
  });
}

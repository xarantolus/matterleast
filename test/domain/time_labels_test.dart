import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/time_labels.dart';

/// Whether the tests run in Central European time, where 2026 switches to
/// summer time on 29 March and back on 25 October.
final _berlin =
    DateTime(2026, 3, 28, 12).timeZoneOffset == const Duration(hours: 1) &&
    DateTime(2026, 3, 29, 12).timeZoneOffset == const Duration(hours: 2) &&
    DateTime(2026, 10, 26, 12).timeZoneOffset == const Duration(hours: 1);

typedef _Row = ({
  DateTime now,
  DateTime at,
  String day,
  String short,
  String? when,
});

void _check(_Row row) {
  expect(dayLabel(row.at, row.now), row.day, reason: 'dayLabel ${row.at}');
  expect(
    shortWhen(row.at, row.now, use24: true),
    row.short,
    reason: 'shortWhen ${row.at}',
  );
  if (row.when case final sentence?) {
    expect(
      whenLabel(row.at, row.now, use24: true),
      sentence,
      reason: 'whenLabel ${row.at}',
    );
  }
}

void main() {
  group('calendar days', () {
    final rows = <_Row>[
      (
        now: DateTime(2026, 10, 20, 12),
        at: DateTime(2026, 10, 20),
        day: 'Today',
        short: '00:00',
        when: '00:00',
      ),
      (
        now: DateTime(2026, 10, 20, 0, 1),
        at: DateTime(2026, 10, 19, 23, 59),
        day: 'Yesterday',
        short: 'Yesterday',
        when: 'yesterday at 23:59',
      ),
      (
        now: DateTime(2026, 10, 20, 23, 59),
        at: DateTime(2026, 10, 20, 0, 1),
        day: 'Today',
        short: '00:01',
        when: '00:01',
      ),
      (
        now: DateTime(2026, 10, 20, 23, 59),
        at: DateTime(2026, 10, 19, 0, 1),
        day: 'Yesterday',
        short: 'Yesterday',
        when: 'yesterday at 00:01',
      ),
      (
        now: DateTime(2027, 1, 1, 0, 1),
        at: DateTime(2026, 12, 31, 23, 59),
        day: 'Yesterday',
        short: 'Yesterday',
        when: 'yesterday at 23:59',
      ),
      (
        now: DateTime(2027, 1, 1, 12),
        at: DateTime(2026, 12, 28, 10),
        day: 'Monday',
        short: 'Mon',
        when: 'Mon at 10:00',
      ),
      (
        now: DateTime(2027, 1, 1, 12),
        at: DateTime(2026, 12, 20, 10),
        day: 'Sun 20 Dec 2026',
        short: '20 Dec 2026',
        when: '20 Dec 2026 at 10:00',
      ),
      (
        now: DateTime(2026, 10, 25, 12),
        at: DateTime(2026, 10, 19, 9),
        day: 'Monday',
        short: 'Mon',
        when: 'Mon at 09:00',
      ),
      (
        now: DateTime(2026, 10, 25, 12),
        at: DateTime(2026, 10, 18, 9),
        day: 'Sun 18 Oct',
        short: '18 Oct',
        when: '18 Oct at 09:00',
      ),
      (
        now: DateTime(2026, 10, 25, 12),
        at: DateTime(2026, 10, 25, 12, 5),
        day: 'Today',
        short: '12:05',
        when: '12:05',
      ),
      (
        now: DateTime(2026, 3, 1),
        at: DateTime(2026, 2, 28, 12),
        day: 'Yesterday',
        short: 'Yesterday',
        when: null,
      ),
      (
        now: DateTime(2028, 3, 1, 8),
        at: DateTime(2028, 2, 29, 12),
        day: 'Yesterday',
        short: 'Yesterday',
        when: null,
      ),
    ];
    for (final (i, row) in rows.indexed) {
      test('row ${i + 1}: ${row.at} seen at ${row.now}', () => _check(row));
    }
  });

  group(
    'clock changes in Europe/Berlin',
    skip: _berlin ? false : 'needs TZ=Europe/Berlin',
    () {
      final rows = <_Row>[
        (
          now: DateTime(2026, 10, 25, 23, 30),
          at: DateTime(2026, 10, 25, 0, 30),
          day: 'Today',
          short: '00:30',
          when: '00:30',
        ),
        (
          now: DateTime(2026, 10, 26, 0, 30),
          at: DateTime(2026, 10, 25, 0, 30),
          day: 'Yesterday',
          short: 'Yesterday',
          when: 'yesterday at 00:30',
        ),
        (
          now: DateTime(2026, 3, 30, 0, 30),
          at: DateTime(2026, 3, 29, 0, 30),
          day: 'Yesterday',
          short: 'Yesterday',
          when: 'yesterday at 00:30',
        ),
        (
          now: DateTime(2026, 3, 29, 3, 30),
          at: DateTime(2026, 3, 29, 1, 30),
          day: 'Today',
          short: '01:30',
          when: '01:30',
        ),
        (
          now: DateTime(2026, 11, 1, 0, 10),
          at: DateTime.utc(2026, 10, 31, 23, 5),
          day: 'Today',
          short: '00:05',
          when: '00:05',
        ),
      ];
      for (final (i, row) in rows.indexed) {
        test('row ${i + 1}: ${row.at} seen at ${row.now}', () => _check(row));
      }

      test('the long and the short day each count as one', () {
        expect(
          DateTime(
            2026,
            10,
            26,
            0,
            30,
          ).difference(DateTime(2026, 10, 25, 0, 30)),
          const Duration(hours: 25),
        );
        expect(
          calendarDaysBetween(
            DateTime(2026, 10, 25, 0, 30),
            DateTime(2026, 10, 26, 0, 30),
          ),
          1,
        );
        expect(
          calendarDaysBetween(
            DateTime(2026, 3, 29, 0, 30),
            DateTime(2026, 3, 30, 0, 30),
          ),
          1,
        );
        expect(
          calendarDaysBetween(
            DateTime(2026, 3, 29, 1, 30),
            DateTime(2026, 3, 29, 3, 30),
          ),
          0,
        );
      });

      test('a status ending at the next midnight ends today', () {
        expect(
          untilLabel(
            DateTime(2026, 10, 26),
            DateTime(2026, 10, 25, 15),
            use24: true,
          ),
          'end of today',
        );
        expect(
          untilLabel(
            DateTime(2026, 10, 26, 9),
            DateTime(2026, 10, 25, 1),
            use24: true,
          ),
          'tomorrow at 09:00',
        );
      });
    },
  );

  group('clock', () {
    test('24 hours with a leading zero', () {
      expect(timeLabel(DateTime(2026, 1, 1, 9, 5), use24: true), '09:05');
      expect(timeLabel(DateTime(2026, 1, 1, 13, 30), use24: true), '13:30');
      expect(timeLabel(DateTime(2026, 1, 1), use24: true), '00:00');
    });

    test('12 hours with AM and PM', () {
      expect(timeLabel(DateTime(2026, 1, 1), use24: false), '12:00 AM');
      expect(timeLabel(DateTime(2026, 1, 1, 0, 1), use24: false), '12:01 AM');
      expect(timeLabel(DateTime(2026, 1, 1, 12), use24: false), '12:00 PM');
      expect(timeLabel(DateTime(2026, 1, 1, 13, 30), use24: false), '1:30 PM');
      expect(
        whenLabel(
          DateTime(2026, 10, 19, 23, 59),
          DateTime(2026, 10, 20, 0, 1),
          use24: false,
        ),
        'yesterday at 11:59 PM',
      );
    });
  });

  group('dates', () {
    test('the year shows when it is not this one, or when asked', () {
      final now = DateTime(2026, 10, 25);
      expect(dateLabel(DateTime(2026, 3, 4), now), '4 Mar');
      expect(dateLabel(DateTime(2025, 3, 4), now), '4 Mar 2025');
      expect(
        dateLabel(DateTime(2026, 3, 4), now, alwaysYear: true),
        '4 Mar 2026',
      );
    });
  });

  group('until', () {
    final now = DateTime(2026, 10, 25, 15);
    final cases = {
      DateTime(2026, 10, 25, 15, 30): '15:30',
      DateTime(2026, 10, 25, 23, 59, 59, 999): 'end of today',
      DateTime(2026, 10, 26): 'end of today',
      DateTime(2026, 10, 26, 9): 'tomorrow at 09:00',
      DateTime(2026, 10, 30, 14): 'Friday at 14:00',
      DateTime(2026, 11, 20, 14): '20 Nov at 14:00',
      DateTime(2027, 11, 20, 14): '20 Nov 2027 at 14:00',
    };
    for (final MapEntry(key: end, value: label) in cases.entries) {
      test('$end reads "$label"', () {
        expect(untilLabel(end, now, use24: true), label);
      });
    }
    test('with a 12-hour clock', () {
      expect(
        untilLabel(DateTime(2026, 10, 26, 9), now, use24: false),
        'tomorrow at 9:00 AM',
      );
    });
  });

  test("someone's local time names the day when it isn't ours", () {
    final now = DateTime(2026, 10, 26, 18);
    expect(
      wallClockLabel(DateTime(2026, 10, 26, 9, 5), now, use24: true),
      '09:05',
    );
    expect(
      wallClockLabel(DateTime(2026, 10, 27, 1, 30), now, use24: true),
      'Tue 01:30',
    );
    expect(
      wallClockLabel(DateTime(2026, 10, 25, 23), now, use24: false),
      'Sun 11:00 PM',
    );
  });
}

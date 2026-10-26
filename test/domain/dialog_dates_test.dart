import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/dialog_rules.dart';

void main() {
  // 10:20 on 31 Jan 2026 in UTC, which is 19:20 in Tokyo.
  final now = DateTime.utc(2026, 1, 31, 10, 20);
  final utc = dialogClock('UTC', now);
  final tokyo = dialogClock('Asia/Tokyo', now);

  DialogElement element(Map<String, Object?> json) =>
      DialogElement.fromJson({'name': 'when', ...json});

  group('reading values and limits', () {
    test('relative days count from the date on the dialog\'s clock', () {
      expect(dialogDate('today', utc), DateTime(2026, 1, 31));
      expect(dialogDate('Tomorrow', utc), DateTime(2026, 2, 1));
      expect(dialogDate('yesterday', utc), DateTime(2026, 1, 30));
      expect(dialogDate('+5d', utc), DateTime(2026, 2, 5));
      expect(dialogDate('-1w', utc), DateTime(2026, 1, 24));
      expect(dialogDate('+1m', utc), DateTime(2026, 2, 28), reason: 'short');
      expect(dialogDate('+14H', utc), DateTime(2026, 2, 1));
      // Already the next day in Tokyo at 19:20 + 5 h.
      expect(dialogDate('+5H', tokyo), DateTime(2026, 2, 1));
    });

    test('ISO dates and datetimes, with and without a zone', () {
      expect(dialogDate('2026-03-10', utc), DateTime(2026, 3, 10));
      expect(dialogDate('2026-02-30', utc), isNull);
      expect(dialogDate('next week', utc), isNull);
      expect(
        dialogMoment('2026-03-10T09:30:00+02:00', utc),
        DateTime.utc(2026, 3, 10, 7, 30),
      );
      expect(
        dialogMoment('2026-03-10T09:30', tokyo),
        DateTime.utc(2026, 3, 10, 0, 30),
        reason: 'a time without a zone is on the dialog\'s clock',
      );
      expect(dialogMoment('+30M', utc), DateTime.utc(2026, 1, 31, 10, 50));
    });

    test('a plain date as a moment: now, start or end of that day', () {
      expect(
        dialogMoment('2026-03-10', tokyo, part: DayPart.start),
        DateTime.utc(2026, 3, 9, 15),
      );
      expect(
        dialogMoment('2026-03-10', utc, part: DayPart.end),
        DateTime.utc(2026, 3, 10, 23, 59, 59),
      );
      expect(dialogMoment('tomorrow', utc), DateTime.utc(2026, 2, 1, 10, 20));
    });
  });

  test('values go out as the server reads them', () {
    expect(formatDialogDate(DateTime(2026, 3, 5)), '2026-03-05');
    expect(
      formatDialogMoment(DateTime.utc(2026, 3, 5, 7, 4, 9, 123)),
      '2026-03-05T07:04:09Z',
    );
    expect(
      formatDialogMoment(tokyo.fromWall(DateTime(2026, 3, 5, 9))),
      '2026-03-05T00:00:00Z',
    );
  });

  test('picked times move to the nearest step on the same day', () {
    expect(
      snapToInterval(DateTime(2026, 1, 1, 10, 20), 30),
      DateTime(2026, 1, 1, 10, 30),
    );
    expect(
      snapToInterval(DateTime(2026, 1, 1, 10, 14), 30),
      DateTime(2026, 1, 1, 10),
    );
    expect(
      snapToInterval(DateTime(2026, 1, 1, 23, 50), 60),
      DateTime(2026, 1, 1, 23),
    );
    expect(
      snapToInterval(DateTime(2026, 1, 1, 10, 7), 1),
      DateTime(2026, 1, 1, 10, 7),
    );
  });

  group('starting values', () {
    test('defaults are read once, relative ones from today', () {
      expect(
        initialDateValue(element({'type': 'date', 'default': 'tomorrow'}), utc),
        '2026-02-01',
      );
      expect(initialDateValue(element({'type': 'date'}), utc), '');
      expect(
        initialDateValue(
          element({'type': 'datetime', 'default': '+2H', 'optional': true}),
          utc,
        ),
        '2026-01-31T12:20:00Z',
      );
    });

    test('a required time with no default starts at the next step, within '
        'the limits', () {
      expect(
        initialDateValue(
          element({
            'type': 'datetime',
            'datetime_config': {'time_interval': 30},
          }),
          utc,
        ),
        '2026-01-31T10:30:00Z',
      );
      expect(
        initialDateValue(element({'type': 'datetime'}), utc),
        '2026-01-31T11:00:00Z',
        reason: 'steps of 60 minutes unless set',
      );
      expect(
        initialDateValue(
          element({
            'type': 'datetime',
            'datetime_config': {'min_date': '2026-02-03'},
          }),
          utc,
        ),
        '2026-02-03T00:00:00Z',
      );
      expect(
        initialDateValue(element({'type': 'datetime', 'optional': true}), utc),
        '',
      );
    });

    test('limits sent the pre-12.0 way still count', () {
      final legacy = element({
        'type': 'datetime',
        'min_date': 'today',
        'time_interval': 15,
      });
      expect(legacy.minDate, 'today');
      expect(legacy.timeInterval, 15);
      expect(
        element({'type': 'datetime', 'time_interval': 7}).timeInterval,
        60,
      );
    });
  });

  group('checks before sending', () {
    final form = DialogForm.fromJson({
      'elements': [
        {
          'name': 'day',
          'type': 'date',
          'datetime_config': {'min_date': 'today', 'max_date': '+7d'},
        },
        {
          'name': 'at',
          'type': 'datetime',
          'datetime_config': {
            'max_date': '2026-02-01T18:00:00Z',
            'location_timezone': 'Asia/Tokyo',
          },
        },
      ],
    });
    Map<String, String> errors(
      Map<String, Object?> values, {
      bool use24 = true,
    }) => dialogErrors(
      form,
      values,
      use24: use24,
      clockFor: (e) => dialogClock(e.datetimeConfig?.locationTimezone, now),
    );

    test('dates and times outside the limits say which are allowed', () {
      expect(errors({'day': '2026-01-30', 'at': '2026-02-02T00:00:00Z'}), {
        'day': 'Pick 31 Jan 2026 or later.',
        'at': 'Pick 2 Feb 2026 at 03:00 or earlier.',
      });
      expect(errors({'day': '2026-02-08', 'at': 'soon'}, use24: false), {
        'day': 'Pick 7 Feb 2026 or earlier.',
        'at': 'Pick a date and time.',
      });
      expect(
        errors({'day': '2026-02-07', 'at': '2026-02-01T18:00:00Z'}),
        isEmpty,
      );
      expect(errors({'day': '', 'at': ''}), {
        'day': 'This field is required.',
        'at': 'This field is required.',
      });
    });
  });
}

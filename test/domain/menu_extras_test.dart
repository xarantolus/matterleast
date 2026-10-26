import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/quote.dart';
import 'package:matterleast/domain/reminders.dart';
import 'package:matterleast/ui/full_screen.dart';

void main() {
  group('reminders', () {
    final now = DateTime(2026, 10, 24, 22, 40);

    test('ready-made times count from now', () {
      expect(
        reminderTime(ReminderChoice.thirtyMinutes, now),
        DateTime(2026, 10, 24, 23, 10),
      );
      expect(
        reminderTime(ReminderChoice.twoHours, now),
        DateTime(2026, 10, 25, 0, 40),
      );
    });

    test('tomorrow is 9:00 on the next local date', () {
      expect(
        reminderTime(ReminderChoice.tomorrow, now),
        DateTime(2026, 10, 25, 9),
      );
      expect(
        reminderTime(ReminderChoice.tomorrow, DateTime(2026, 12, 31, 0, 5)),
        DateTime(2027, 1, 1, 9),
      );
    });
  });

  group('quotes', () {
    test('every line is quoted and the link follows', () {
      expect(
        quoteOf('first\n\nsecond\n', permalink: 'https://x.test/t/pl/p1'),
        '> first\n>\n> second\n\nhttps://x.test/t/pl/p1\n\n',
      );
      expect(quoteOf('only'), '> only\n\n');
    });

    test('a quote goes after what is written, a blank line apart', () {
      expect(withQuote('', '> q\n\n'), '> q\n\n');
      expect(withQuote('hello', '> q\n\n'), 'hello\n\n> q\n\n');
      expect(withQuote('hello\n', '> q\n\n'), 'hello\n\n> q\n\n');
      expect(withQuote('hello\n\n', '> q\n\n'), 'hello\n\n> q\n\n');
    });
  });

  test('guests are told by their system role', () {
    expect(isGuest('system_guest'), isTrue);
    expect(isGuest('system_user system_guest'), isTrue);
    expect(isGuest('system_user'), isFalse);
    expect(isGuest('system_guests'), isFalse);
    expect(isGuest(null), isFalse);
  });

  test('only wide full-screen video turns, and only with rotation on', () {
    expect(fullScreenOrientations(wide: true, autoRotate: true), const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    expect(fullScreenOrientations(wide: true, autoRotate: false), isEmpty);
    expect(fullScreenOrientations(wide: false, autoRotate: true), isEmpty);
  });
}

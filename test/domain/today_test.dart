import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/today.dart';

void main() {
  test('the day starts at local midnight', () {
    expect(localDay(DateTime(2026, 10, 25, 23, 59)), DateTime(2026, 10, 25));
    expect(localDay(DateTime(2026, 10, 26)), DateTime(2026, 10, 26));
  });

  test('the next day begins at the coming midnight', () {
    final now = DateTime(2026, 10, 25, 23, 59, 30);
    expect(now.add(untilNextDay(now)), DateTime(2026, 10, 26));
    final early = DateTime(2026, 3, 1, 0, 0, 1);
    expect(early.add(untilNextDay(early)), DateTime(2026, 3, 2));
  });

  test('the short and the long day end at their own midnight', () {
    // A 23-hour and a 25-hour day where the clocks change (CI runs in
    // Europe/Berlin, where they do on these dates).
    for (final (now, next) in [
      (DateTime(2026, 3, 28, 23, 30), DateTime(2026, 3, 29)),
      (DateTime(2026, 3, 29, 12), DateTime(2026, 3, 30)),
      (DateTime(2026, 10, 25, 1, 30), DateTime(2026, 10, 26)),
      (DateTime(2026, 10, 25, 12), DateTime(2026, 10, 26)),
    ]) {
      expect(now.add(untilNextDay(now)), next, reason: '$now');
      expect(localDay(now.add(untilNextDay(now))), next);
    }
  });
}

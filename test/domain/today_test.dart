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
}

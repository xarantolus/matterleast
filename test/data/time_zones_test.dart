import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/time_zones.dart';

void main() {
  test("another person's local time follows their zone into summer time", () {
    expect(
      wallTimeIn('Europe/Lisbon', DateTime.utc(2026, 3, 29, 0, 30)),
      DateTime(2026, 3, 29, 0, 30),
    );
    expect(
      wallTimeIn('Europe/Lisbon', DateTime.utc(2026, 3, 29, 1, 30)),
      DateTime(2026, 3, 29, 2, 30),
    );
  });

  test('the hour that repeats in autumn shows twice', () {
    expect(
      wallTimeIn('Europe/Berlin', DateTime.utc(2026, 10, 25, 0, 30)),
      DateTime(2026, 10, 25, 2, 30),
    );
    expect(
      wallTimeIn('Europe/Berlin', DateTime.utc(2026, 10, 25, 1, 30)),
      DateTime(2026, 10, 25, 2, 30),
    );
  });

  test('a zone with an odd offset lands on the right day', () {
    expect(
      wallTimeIn('America/St_Johns', DateTime.utc(2026, 1, 1, 2)),
      DateTime(2025, 12, 31, 22, 30),
    );
  });

  test('a zone the database does not know gives no time', () {
    expect(wallTimeIn('Mars/Olympus_Mons', DateTime.utc(2026)), isNull);
  });
}

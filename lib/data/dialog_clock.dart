import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/time_zones.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:timezone/timezone.dart' as tz;

/// The clock [element]'s dates are read on now.
DialogClock clockForElement(DialogElement element) =>
    dialogClock(element.datetimeConfig?.locationTimezone, DateTime.now());

/// The clock for a dialog at [now]: in the IANA [zone] the integration
/// named, or the phone's when it named none or one the database lacks.
DialogClock dialogClock(String? zone, DateTime now) {
  if (zone == null || zone.isEmpty || wallTimeIn(zone, now) == null) {
    return DialogClock(now: now);
  }
  final location = tz.getLocation(zone);
  return DialogClock(
    now: now,
    zone: zone,
    toWall: (moment) {
      final t = tz.TZDateTime.from(moment, location);
      return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
    },
    fromWall: (wall) => tz.TZDateTime(
      location,
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
    ).toUtc(),
  );
}

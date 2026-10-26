import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

var _loaded = false;

void _load() {
  if (_loaded) return;
  tz_data.initializeTimeZones();
  _loaded = true;
}

/// Every IANA zone the database knows, in name order.
List<String> allTimeZones() {
  _load();
  return [
    for (final name in tz.timeZoneDatabase.locations.keys)
      if (name.contains('/') && !name.startsWith('Etc/')) name,
  ]..sort();
}

/// The wall-clock time in the IANA zone [zone] at [now], or null for a zone
/// the database doesn't know. The database loads on first use.
DateTime? wallTimeIn(String zone, DateTime now) {
  _load();
  final tz.Location location;
  try {
    location = tz.getLocation(zone);
  } on tz.LocationNotFoundException {
    return null;
  }
  final t = tz.TZDateTime.from(now, location);
  return DateTime(t.year, t.month, t.day, t.hour, t.minute);
}

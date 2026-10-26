import 'package:matterleast/api/websocket/dialog.dart';

/// The moment a dialog is filled in, and the wall clock its dates and times
/// are shown and picked in: the phone's, or the zone the integration named.
/// Wall times are local [DateTime]s whose fields are the clock's reading.
class DialogClock {
  DialogClock({
    required DateTime now,
    DateTime Function(DateTime moment)? toWall,
    DateTime Function(DateTime wall)? fromWall,
    this.zone,
  }) : now = now.toUtc(),
       toWall = toWall ?? ((m) => m.toLocal()),
       fromWall = fromWall ?? ((w) => w.toUtc());

  final DateTime now;

  /// The wall time at a moment.
  final DateTime Function(DateTime moment) toWall;

  /// The moment, in UTC, of a wall time.
  final DateTime Function(DateTime wall) fromWall;

  /// The IANA zone named by the integration; null is the phone's.
  final String? zone;

  DateTime get today {
    final wall = toWall(now);
    return DateTime(wall.year, wall.month, wall.day);
  }
}

/// What to do with a date where a moment is needed.
enum DayPart {
  /// The current time of day, as for a value.
  now,

  /// Midnight, as for an earliest allowed moment.
  start,

  /// The last second, as for a latest allowed moment.
  end,
}

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
final _offsetPattern = RegExp(r'^([+-]\d{1,4})([dwmHMS])$');

/// Pure: the calendar date of a dialog value or bound: `YYYY-MM-DD`, an
/// ISO datetime (its date on the dialog's clock), or relative (`today`,
/// `tomorrow`, `yesterday`, `+5d`, `-2w`, `+1m`, `+3H`, `+30M`, `+90S`).
DateTime? dialogDate(String raw, DialogClock clock) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final day = _relativeDay(text, clock) ?? _isoDate(text);
  if (day != null) return day;
  final moment = _relativeMoment(text, clock) ?? _isoMoment(text, clock);
  if (moment == null) return null;
  final wall = clock.toWall(moment);
  return DateTime(wall.year, wall.month, wall.day);
}

/// Pure: the moment (UTC) of a dialog value or bound, read like
/// [dialogDate]; a plain date becomes a moment on that day as [part] says.
DateTime? dialogMoment(
  String raw,
  DialogClock clock, {
  DayPart part = DayPart.now,
}) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final moment = _relativeMoment(text, clock) ?? _isoMoment(text, clock);
  if (moment != null) return moment;
  final day = _relativeDay(text, clock) ?? _isoDate(text);
  if (day == null) return null;
  final time = clock.toWall(clock.now);
  final wall = switch (part) {
    DayPart.now => DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    ),
    DayPart.start => day,
    DayPart.end => DateTime(day.year, day.month, day.day, 23, 59, 59),
  };
  return clock.fromWall(wall);
}

/// `YYYY-MM-DD`, as the server expects date fields.
String formatDialogDate(DateTime day) =>
    '${_pad(day.year, 4)}-${_pad(day.month)}-${_pad(day.day)}';

/// UTC `YYYY-MM-DDTHH:MM:SSZ`, as the server expects datetime fields.
String formatDialogMoment(DateTime moment) {
  final m = moment.toUtc();
  return '${formatDialogDate(m)}T${_pad(m.hour)}:${_pad(m.minute)}:'
      '${_pad(m.second)}Z';
}

/// Pure: [wall] moved to the nearest step of [minutes] on the same day.
DateTime snapToInterval(DateTime wall, int minutes) {
  if (minutes <= 1) {
    return DateTime(wall.year, wall.month, wall.day, wall.hour, wall.minute);
  }
  final ofDay = wall.hour * 60 + wall.minute;
  var snapped = (ofDay / minutes).round() * minutes;
  if (snapped >= 24 * 60) snapped -= minutes;
  return DateTime(wall.year, wall.month, wall.day, 0, snapped);
}

/// Pure: the value a date or datetime field starts with: its default read
/// as the server sends it, else, for a required datetime, the next time
/// step from now within the allowed range (as the official clients do).
String initialDateValue(DialogElement element, DialogClock clock) {
  final raw = element.defaultValue ?? '';
  switch (element.type) {
    case DialogElementType.date:
      final day = dialogDate(raw, clock);
      return day == null ? '' : formatDialogDate(day);
    case DialogElementType.datetime:
      final given = dialogMoment(raw, clock);
      if (given != null) return formatDialogMoment(given);
      if (element.optional ?? false) return '';
      final wall = clock.toWall(clock.now);
      final step = element.timeInterval;
      final ofDay = wall.hour * 60 + wall.minute;
      final next = (ofDay / step).ceil() * step;
      var moment = clock.fromWall(
        DateTime(wall.year, wall.month, wall.day, 0, next),
      );
      final (min, max) = momentBounds(element, clock);
      if (min != null && moment.isBefore(min)) moment = min;
      if (max != null && moment.isAfter(max)) moment = max;
      return formatDialogMoment(moment);
    default:
      return raw;
  }
}

/// Pure: the earliest and latest dates a date field allows.
(DateTime?, DateTime?) dateBounds(DialogElement element, DialogClock clock) => (
  dialogDate(element.minDate ?? '', clock),
  dialogDate(element.maxDate ?? '', clock),
);

/// Pure: the earliest and latest moments a datetime field allows.
(DateTime?, DateTime?) momentBounds(DialogElement element, DialogClock clock) =>
    (
      dialogMoment(element.minDate ?? '', clock, part: DayPart.start),
      dialogMoment(element.maxDate ?? '', clock, part: DayPart.end),
    );

DateTime? _relativeDay(String text, DialogClock clock) {
  final today = clock.today;
  switch (text.toLowerCase()) {
    case 'today':
      return today;
    case 'tomorrow':
      return DateTime(today.year, today.month, today.day + 1);
    case 'yesterday':
      return DateTime(today.year, today.month, today.day - 1);
  }
  final match = _offsetPattern.firstMatch(text);
  if (match == null) return null;
  final amount = int.parse(match.group(1)!);
  return switch (match.group(2)) {
    'd' => DateTime(today.year, today.month, today.day + amount),
    'w' => DateTime(today.year, today.month, today.day + 7 * amount),
    'm' => _addMonths(today, amount),
    _ => null,
  };
}

DateTime? _relativeMoment(String text, DialogClock clock) {
  final match = _offsetPattern.firstMatch(text);
  if (match == null) return null;
  final amount = int.parse(match.group(1)!);
  return switch (match.group(2)) {
    'H' => clock.now.add(Duration(hours: amount)),
    'M' => clock.now.add(Duration(minutes: amount)),
    'S' => clock.now.add(Duration(seconds: amount)),
    _ => null,
  };
}

/// The same day [months] later, or the month's last day when it is shorter.
DateTime _addMonths(DateTime day, int months) {
  final first = DateTime(day.year, day.month + months);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, day.day > last ? last : day.day);
}

DateTime? _isoDate(String text) {
  final match = _datePattern.firstMatch(text);
  if (match == null) return null;
  final [year, month, day] = [
    for (var i = 1; i <= 3; i++) int.parse(match.group(i)!),
  ];
  final date = DateTime(year, month, day);
  return date.month == month && date.day == day ? date : null;
}

/// An ISO datetime; one without a zone is a wall time on the clock.
DateTime? _isoMoment(String text, DialogClock clock) {
  if (!text.contains('T')) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  return parsed.isUtc ? parsed : clock.fromWall(parsed);
}

String _pad(int value, [int width = 2]) => value.toString().padLeft(width, '0');

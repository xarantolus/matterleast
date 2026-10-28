/// Every date and time the app shows, in the local time zone. Days are
/// compared as calendar dates, never as spans of 24 hours, so "Yesterday"
/// is the previous local date even across a clock change.
library;

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Calendar days from the local date of [from] to that of [to].
int calendarDaysBetween(DateTime from, DateTime to) {
  final a = from.toLocal();
  final b = to.toLocal();
  return DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// "14:05" or "2:05 PM".
String timeLabel(DateTime at, {required bool use24}) {
  final local = at.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  if (use24) return '${local.hour.toString().padLeft(2, '0')}:$minute';
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}

/// Days ago; a moment on the next day (a phone clock behind the server's)
/// counts as today.
int _daysAgo(DateTime at, DateTime now) {
  final days = calendarDaysBetween(at, now);
  return days == -1 ? 0 : days;
}

/// Day separators and day headers: "Today", "Yesterday", the weekday name
/// within the past week, "Tue 20 Oct", or "Tue 20 Oct 2025".
String dayLabel(DateTime at, DateTime now) {
  final local = at.toLocal();
  final days = _daysAgo(local, now);
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days > 1 && days < 7) return _weekdayNames[local.weekday - 1];
  final label =
      '${_weekdays[local.weekday - 1]} ${local.day} ${_months[local.month - 1]}';
  return local.year == now.toLocal().year ? label : '$label ${local.year}';
}

/// List rows: the time today, "Yesterday", "Tue" within the past week,
/// "20 Oct", or "20 Oct 2025".
String shortWhen(DateTime at, DateTime now, {required bool use24}) {
  final local = at.toLocal();
  final days = _daysAgo(local, now);
  if (days == 0) return timeLabel(local, use24: use24);
  if (days == 1) return 'Yesterday';
  if (days > 1 && days < 7) return _weekdays[local.weekday - 1];
  return dateLabel(local, now);
}

/// One moment inside a sentence: "14:05" today, "yesterday at 14:05",
/// "Tue at 14:05" within the past week, "20 Oct at 14:05", or
/// "20 Oct 2025 at 14:05".
String whenLabel(DateTime at, DateTime now, {required bool use24}) {
  final local = at.toLocal();
  final time = timeLabel(local, use24: use24);
  final days = _daysAgo(local, now);
  if (days == 0) return time;
  if (days == 1) return 'yesterday at $time';
  if (days > 1 && days < 7) return '${_weekdays[local.weekday - 1]} at $time';
  return '${dateLabel(local, now)} at $time';
}

/// One moment on its own, such as when a message was edited: "14:05"
/// today, "Yesterday, 14:05", "20 Oct, 14:05", or "20 Oct 2025, 14:05".
String momentLabel(DateTime at, DateTime now, {required bool use24}) {
  final local = at.toLocal();
  final time = timeLabel(local, use24: use24);
  final days = _daysAgo(local, now);
  if (days == 0) return time;
  if (days == 1) return 'Yesterday, $time';
  return '${dateLabel(local, now)}, $time';
}

/// "Tuesday, 27 October 2026 at 14:05".
String fullMomentLabel(DateTime at, {required bool use24}) {
  final local = at.toLocal();
  return '${_weekdayNames[local.weekday - 1]}, ${local.day} '
      '${_monthNames[local.month - 1]} ${local.year} at '
      '${timeLabel(local, use24: use24)}';
}

/// A date without a time: "20 Oct", with the year when it isn't this one
/// or when [alwaysYear] is set.
String dateLabel(DateTime at, DateTime now, {bool alwaysYear = false}) {
  final local = at.toLocal();
  final label = '${local.day} ${_months[local.month - 1]}';
  return alwaysYear || local.year != now.toLocal().year
      ? '$label ${local.year}'
      : label;
}

/// When something ahead ends, for "until …": "15:30" today, "end of today"
/// at the last minute of today or the midnight after it, "tomorrow at
/// 09:00", "Friday at 14:00" within the week, then "20 Nov at 14:00".
String untilLabel(DateTime end, DateTime now, {required bool use24}) {
  final local = end.toLocal();
  final days = calendarDaysBetween(now, local);
  final lastMinute = local.hour == 23 && local.minute == 59;
  final midnight =
      local.hour == 0 &&
      local.minute == 0 &&
      local.second == 0 &&
      local.millisecond == 0;
  if ((days == 0 && lastMinute) || (days == 1 && midnight)) {
    return 'end of today';
  }
  final time = timeLabel(local, use24: use24);
  if (days <= 0) return time;
  if (days == 1) return 'tomorrow at $time';
  if (days < 7) return '${_weekdayNames[local.weekday - 1]} at $time';
  return '${dateLabel(local, now)} at $time';
}

/// Someone's wall-clock time [wall] in their own zone, as seen at [now]:
/// "01:30", or "Tue 01:30" when their date differs from ours.
String wallClockLabel(DateTime wall, DateTime now, {required bool use24}) {
  final time = timeLabel(wall, use24: use24);
  return calendarDaysBetween(now, wall) == 0
      ? time
      : '${_weekdays[wall.weekday - 1]} $time';
}

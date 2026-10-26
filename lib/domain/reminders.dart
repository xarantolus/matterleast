import 'package:matterleast/domain/today.dart';

/// The ready-made times "Remind me" offers; a custom time is picked.
enum ReminderChoice { thirtyMinutes, oneHour, twoHours, tomorrow }

/// Pure: when a reminder chosen at [now] is due.
DateTime reminderTime(ReminderChoice choice, DateTime now) => switch (choice) {
  ReminderChoice.thirtyMinutes => now.add(const Duration(minutes: 30)),
  ReminderChoice.oneHour => now.add(const Duration(hours: 1)),
  ReminderChoice.twoHours => now.add(const Duration(hours: 2)),
  ReminderChoice.tomorrow => tomorrowMorning(now),
};

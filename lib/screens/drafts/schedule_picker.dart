import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/scheduled_posts.dart';
import 'package:matterleast/domain/time_labels.dart';

/// Asks when a message should go out: tomorrow or Monday morning, or a day
/// and time of the user's choice, on the clock of [zone] (the user's
/// profile zone; null for the phone's). Null when the user backs out.
Future<DateTime?> pickScheduleTime(
  BuildContext context, {
  String? zone,
  String title = 'Schedule message',
}) async {
  final clock = dialogClock(zone, DateTime.now());
  final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final nine = timeLabel(DateTime(2000, 1, 1, 9), use24: use24);
  final presets = schedulePresets(clock, nine: nine);
  final choice = await showModalBottomSheet<DateTime?>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(title, style: Theme.of(sheet).textTheme.titleMedium),
          ),
          for (final p in presets)
            ListTile(
              leading: const Icon(Icons.schedule_send_outlined),
              title: Text(p.label),
              subtitle: Text(_day(clock.toWall(p.at), clock)),
              onTap: () => Navigator.of(sheet).pop(p.at),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Custom time'),
            subtitle: zone == null ? null : Text('In $zone'),
            onTap: () => Navigator.of(sheet).pop(_custom),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;
  if (choice != _custom) return choice;
  return _pickCustom(context, clock);
}

/// Stands for "Custom time" in the sheet's answer.
final _custom = DateTime.utc(1970);

Future<DateTime?> _pickCustom(BuildContext context, DialogClock clock) async {
  final today = clock.today;
  final day = await showDatePicker(
    context: context,
    initialDate: today.add(const Duration(days: 1)),
    firstDate: today,
    lastDate: DateTime(today.year + 1, today.month, today.day),
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );
  if (time == null || !context.mounted) return null;
  final at = clock.fromWall(
    DateTime(day.year, day.month, day.day, time.hour, time.minute),
  );
  if (!at.isAfter(DateTime.now())) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pick a time in the future.')));
    return null;
  }
  return at;
}

String _day(DateTime wall, DialogClock clock) {
  final today = clock.today;
  return dateLabel(wall, today);
}

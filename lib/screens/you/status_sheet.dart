import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/sheet_header.dart';

/// Lets the user pick their presence on [url]; do not disturb asks how
/// long.
Future<void> showStatusSheet(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String current,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final status = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in const ['online', 'away', 'dnd', 'offline'])
            ListTile(
              leading: SizedBox(
                width: 40,
                child: Center(
                  child: PresenceDot(status: s, size: 16, announce: false),
                ),
              ),
              title: Text(presenceLabel(s)),
              subtitle: s == 'dnd'
                  ? const Text('Notifications are paused')
                  : null,
              trailing: s == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, s),
            ),
        ],
      ),
    ),
  );
  if (status == null || !context.mounted) return;
  DateTime? until;
  if (status == 'dnd') {
    final length = await _askDndLength(context);
    if (length == null) return;
    until = dndEnd(length, DateTime.now());
  }
  try {
    final actions = await ref.read(profileActionsProvider(url).future);
    await actions.setStatus(status, dndEnd: until);
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't change your status. "
          '${requestProblemText(e, Uri.parse(url).host)}',
        ),
      ),
    );
  }
}

Future<DndLength?> _askDndLength(
  BuildContext context,
) => showModalBottomSheet<DndLength>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader('Do not disturb for'),
        for (final length in DndLength.values)
          ListTile(
            title: Text(switch (length) {
              DndLength.untilChanged => 'Until I change it',
              DndLength.thirtyMinutes => '30 minutes',
              DndLength.oneHour => '1 hour',
              DndLength.twoHours => '2 hours',
              DndLength.tomorrow =>
                'Until tomorrow at ${timeLabel(DateTime(2000, 1, 1, 9), use24: MediaQuery.alwaysUse24HourFormatOf(context))}',
            }),
            onTap: () => Navigator.pop(context, length),
          ),
      ],
    ),
  ),
);

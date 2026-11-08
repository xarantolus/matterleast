import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/tokens.dart';

/// The small-caps title over a group of settings.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.lg,
      Spacing.lg,
      Spacing.lg,
      Spacing.sm,
    ),
    child: Text(text.toUpperCase(), style: context.tokens.smallCaps),
  );
}

/// Asks for one of [options]; null when dismissed or nothing changed.
Future<T?> pickOne<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T current,
  required String Function(T) label,
}) async {
  if (usesCupertinoDialogs) {
    final picked = await showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          for (final option in options)
            CupertinoActionSheetAction(
              isDefaultAction: option == current,
              onPressed: () => Navigator.of(context).pop(option),
              child: Text(label(option)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
    return picked == current ? null : picked;
  }
  final picked = await showDialog<T>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(title),
      children: [
        RadioGroup<T>(
          groupValue: current,
          onChanged: (value) => Navigator.of(context).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                RadioListTile<T>(value: option, title: Text(label(option))),
            ],
          ),
        ),
      ],
    ),
  );
  return picked == current ? null : picked;
}

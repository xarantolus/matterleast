import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/ui/tokens.dart';

/// Pure: the tooltip of a format button, with its shortcut.
String formatTooltip(Format format) {
  final shortcut = appShortcuts.firstWhere((s) {
    final intent = s.intent;
    return intent is FormatIntent && intent.format == format;
  });
  return '${shortcut.description} (${keysLabel(shortcut.keys)})';
}

/// Buttons that format the composer's selection, as the shortcuts do.
class FormatBar extends StatelessWidget {
  const FormatBar({required this.onFormat, super.key});

  final ValueChanged<Format> onFormat;

  static const _icons = {
    Format.bold: Icons.format_bold,
    Format.italic: Icons.format_italic,
    Format.strike: Icons.strikethrough_s,
    Format.link: Icons.link,
    Format.code: Icons.code,
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.xs),
    child: Row(
      children: [
        for (final format in Format.values)
          IconButton(
            tooltip: formatTooltip(format),
            iconSize: 18,
            onPressed: () => onFormat(format),
            icon: Icon(_icons[format]),
          ),
      ],
    ),
  );
}

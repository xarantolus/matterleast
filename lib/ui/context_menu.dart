import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A popup menu with [items] at [position] (global), as a right click opens
/// one, on the window's overlay rather than a pane's.
Future<T?> showMenuAt<T>(
  BuildContext context,
  Offset position,
  List<PopupMenuEntry<T>> items,
) {
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final at = overlay.globalToLocal(position);
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(at.dx, at.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    items: items,
  );
}

/// An entry of a menu from [showMenuAt]: an icon and a label, in [color]
/// for what destroys something.
class MenuEntry extends StatelessWidget {
  const MenuEntry({
    required this.icon,
    required this.label,
    this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: Spacing.md),
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color),
        ),
      ),
    ],
  );
}

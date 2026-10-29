import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/density.dart';
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

/// A menu row as high as the density says, a [PopupMenuItem] otherwise.
class MenuItem<T> extends PopupMenuEntry<T> {
  const MenuItem({required this.value, required this.child, super.key});

  final T value;
  final Widget child;

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(T? value) => value == this.value;

  @override
  State<MenuItem<T>> createState() => _MenuItemState<T>();
}

class _MenuItemState<T> extends State<MenuItem<T>> {
  @override
  Widget build(BuildContext context) => PopupMenuItem<T>(
    value: widget.value,
    height: context.density.menuRowHeight ?? kMinInteractiveDimension,
    child: widget.child,
  );
}

/// An entry of a menu from [showMenuAt]: an icon and a label, in [color]
/// for what destroys something, and the [shortcut] that does the same.
class MenuEntry extends StatelessWidget {
  const MenuEntry({
    required this.icon,
    required this.label,
    this.color,
    this.shortcut,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final String? shortcut;

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
      if (shortcut != null) ...[
        const Spacer(),
        const SizedBox(width: Spacing.lg),
        Text(
          shortcut!,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.tokens.muted),
        ),
      ],
    ],
  );
}

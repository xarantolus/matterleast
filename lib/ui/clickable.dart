import 'package:flutter/widgets.dart';

/// The hand a mouse shows over anything a click acts on; the arrow where
/// the control is disabled. Flutter's own default on desktop is the arrow,
/// so the desktop theme gives it to Material's buttons, [InkWell]s and
/// chips take it as `mouseCursor`, and plain gestures get it from
/// [Clickable]. Text spans with a recognizer show it by themselves.
const MouseCursor clickCursor = WidgetStateMouseCursor.clickable;

/// [child] with the hand cursor (or [cursor]), for a plain gesture that a
/// click acts on, such as a [GestureDetector]'s `onTap`.
class Clickable extends StatelessWidget {
  const Clickable({
    required this.child,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
    super.key,
  });

  final Widget child;

  /// Without it, the cursor is left to what is around.
  final bool enabled;
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) =>
      MouseRegion(cursor: enabled ? cursor : MouseCursor.defer, child: child);
}

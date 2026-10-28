import 'package:flutter/widgets.dart';

/// The hand over enabled controls; Flutter's desktop default is the arrow.
const MouseCursor clickCursor = WidgetStateMouseCursor.clickable;

/// The hand (or [cursor]) over a plain gesture's [child].
class Clickable extends StatelessWidget {
  const Clickable({
    required this.child,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
    super.key,
  });

  final Widget child;

  final bool enabled;
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) =>
      MouseRegion(cursor: enabled ? cursor : MouseCursor.defer, child: child);
}

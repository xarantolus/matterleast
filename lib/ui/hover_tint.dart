import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/motion.dart';

/// The shade over a picture under the mouse.
const pictureHoverTint = Color(0x1F000000);

/// Shades [child], a picture that opens on a click, while the mouse is over
/// it, fading in and out. Touch leaves it as it is.
class HoverTint extends StatefulWidget {
  const HoverTint({
    required this.child,
    this.cursor = SystemMouseCursors.click,
    super.key,
  });

  final Widget child;
  final MouseCursor cursor;

  @override
  State<HoverTint> createState() => _HoverTintState();
}

class _HoverTintState extends State<HoverTint> {
  var _over = false;

  void _hover(bool over) {
    if (over != _over) setState(() => _over = over);
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.cursor,
    onEnter: (_) => _hover(true),
    onExit: (_) => _hover(false),
    child: TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: _over ? pictureHoverTint : Colors.transparent),
      duration: motion(context, const Duration(milliseconds: 120)),
      builder: (context, tint, child) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(color: tint),
        child: child,
      ),
      child: widget.child,
    ),
  );
}

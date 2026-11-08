import 'package:material_ui/material_ui.dart';

/// A [Tooltip] that is only made once a mouse first comes over [child], for
/// things shown by the hundred, such as the emoji in a message: each tooltip
/// holds a ticker, an overlay and mouse tracking, which made scrolling such
/// messages stutter. Once made it stays, so it shows and fades as usual.
class HoverTooltip extends StatefulWidget {
  const HoverTooltip({required this.message, required this.child, super.key});

  final String message;
  final Widget child;

  @override
  State<HoverTooltip> createState() => _HoverTooltipState();
}

class _HoverTooltipState extends State<HoverTooltip> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: _hovered ? null : (_) => setState(() => _hovered = true),
    child: _hovered
        ? Tooltip(message: widget.message, child: widget.child)
        : Semantics(tooltip: widget.message, child: widget.child),
  );
}

import 'package:material_ui/material_ui.dart';

/// Shows an animated picture still until the pointer is over it, so an idle
/// window draws no frames. With [hoverOnly] false it always plays.
class PlayOnHover extends StatefulWidget {
  const PlayOnHover({required this.hoverOnly, required this.child, super.key});

  final bool hoverOnly;
  final Widget child;

  @override
  State<PlayOnHover> createState() => _PlayOnHoverState();
}

class _PlayOnHoverState extends State<PlayOnHover> {
  var _hovering = false;

  void _hover(bool value) => setState(() => _hovering = value);

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => _hover(true),
    onExit: (_) => _hover(false),
    child: TickerMode(
      enabled: !widget.hoverOnly || _hovering,
      child: widget.child,
    ),
  );
}

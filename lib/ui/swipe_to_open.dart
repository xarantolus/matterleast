import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/slide_route.dart';

/// Lets [child] be pulled to the left; past a threshold it clicks and,
/// once let go, calls [onOpen]. Vertical scrolling wins over small
/// sideways movement, so scrolling doesn't trigger it.
class SwipeToOpen extends StatefulWidget {
  const SwipeToOpen({required this.onOpen, required this.child, super.key});

  final VoidCallback onOpen;
  final Widget child;

  @override
  State<SwipeToOpen> createState() => _SwipeToOpenState();
}

class _SwipeToOpenState extends State<SwipeToOpen> {
  static const _threshold = 64.0;
  static const _max = 96.0;
  var _dx = 0.0;

  void _update(DragUpdateDetails d) {
    final next = (_dx + d.delta.dx).clamp(-_max, 0.0);
    if (_dx > -_threshold && next <= -_threshold) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _dx = next);
  }

  void _end(DragEndDetails _) {
    final open = _dx <= -_threshold;
    setState(() => _dx = 0);
    if (open) widget.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final reached = _dx <= -_threshold;
    return RawGestureDetector(
      gestures: {
        OneWayDragRecognizer:
            GestureRecognizerFactoryWithHandlers<OneWayDragRecognizer>(
              () => OneWayDragRecognizer(rightward: false, debugOwner: this),
              (r) => r
                ..onUpdate = _update
                ..onEnd = _end
                ..onCancel = () => setState(() => _dx = 0),
            ),
      },
      child: Stack(
        children: [
          if (_dx < 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.more_horiz,
                    color: reached
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          Transform.translate(offset: Offset(_dx, 0), child: widget.child),
        ],
      ),
    );
  }
}

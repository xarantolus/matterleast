import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// How far from the anchor the pointer must be before anything scrolls.
const autoscrollDeadZone = 12.0;

const _autoscrollGain = 10.0;
const _autoscrollTopSpeed = 4000.0;

/// Pure: the scroll speed in pixels per second for a pointer [away] from
/// the anchor; zero in the dead zone, then growing with the distance.
Offset autoscrollVelocity(Offset away) =>
    Offset(_axisSpeed(away.dx), _axisSpeed(away.dy));

double _axisSpeed(double distance) {
  final beyond = distance.abs() - autoscrollDeadZone;
  if (beyond <= 0) return 0;
  return math.min(beyond * _autoscrollGain, _autoscrollTopSpeed) *
      distance.sign;
}

/// Middle-button autoscroll, as in browsers on Windows and Linux: press
/// the middle button over a scroll view, move away from the press and it
/// scrolls faster the further you go. Holding and releasing after a drag
/// stops it; a click without a drag keeps it going until the next click or
/// Esc. A middle click on a link still opens it, as its own recognizer
/// wins the click.
///
/// It sends ordinary wheel events at the anchor, so whatever scroll view
/// is there scrolls by its own physics.
class MiddleAutoscroll extends StatefulWidget {
  const MiddleAutoscroll({required this.child, super.key});

  final Widget child;

  @override
  State<MiddleAutoscroll> createState() => _MiddleAutoscrollState();
}

class _MiddleAutoscrollState extends State<MiddleAutoscroll>
    with SingleTickerProviderStateMixin {
  late final _ticker = createTicker(_tick);
  Offset? _anchor;
  var _pointer = Offset.zero;
  var _holding = false;
  var _stoppedByPress = false;
  var _lastFrame = Duration.zero;
  final _focus = FocusNode(debugLabel: 'Autoscroll', skipTraversal: true);
  FocusNode? _before;

  @override
  void dispose() {
    _focus.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _start(Offset at, {required bool holding}) {
    if (_stoppedByPress) return;
    setState(() {
      _anchor = at;
      _pointer = at;
      _holding = holding;
    });
    _lastFrame = Duration.zero;
    _ticker.start();
    // Esc needs a focus to arrive at; the focus goes back afterwards.
    if (!holding) {
      _before = FocusManager.instance.primaryFocus;
      _focus.requestFocus();
    }
  }

  void _stop() {
    if (_anchor == null) return;
    _ticker.stop();
    setState(() => _anchor = null);
    if (_focus.hasPrimaryFocus) {
      final before = _before;
      if (before != null && before.context != null) before.requestFocus();
      if (!_focus.hasPrimaryFocus) _focus.unfocus();
    }
    _before = null;
  }

  void _tick(Duration elapsed) {
    final anchor = _anchor;
    if (anchor == null) return;
    final seconds = (elapsed - _lastFrame).inMicroseconds / 1e6;
    _lastFrame = elapsed;
    final step = autoscrollVelocity(_pointer - anchor) * seconds;
    if (step == Offset.zero) return;
    GestureBinding.instance.handlePointerEvent(
      PointerScrollEvent(
        viewId: View.of(context).viewId,
        kind: PointerDeviceKind.trackpad,
        position: anchor,
        scrollDelta: step,
      ),
    );
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (_anchor == null ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    _stop();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final anchor = _anchor;
    final box = context.findRenderObject();
    final marker = anchor == null || box is! RenderBox
        ? null
        : box.globalToLocal(anchor);
    return Focus(
      focusNode: _focus,
      onKeyEvent: _key,
      child: Listener(
        onPointerDown: (e) {
          if (e.buttons != kTertiaryButton) _stop();
        },
        onPointerHover: (e) => _pointer = e.position,
        onPointerMove: (e) => _pointer = e.position,
        child: RawGestureDetector(
          gestures: {
            _MiddleButtonRecognizer:
                GestureRecognizerFactoryWithHandlers<_MiddleButtonRecognizer>(
                  _MiddleButtonRecognizer.new,
                  (r) {
                    r.onPress = (_) {
                      _stoppedByPress = _anchor != null;
                      _stop();
                    };
                    r.onDragStart = (at) => _start(at, holding: true);
                    r.onDragUpdate = (at) => _pointer = at;
                    r.onDragEnd = () {
                      if (_holding) _stop();
                    };
                    r.onClick = (at) => _start(at, holding: false);
                  },
                ),
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              if (marker != null) ...[
                const Positioned.fill(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.allScroll,
                    hitTestBehavior: HitTestBehavior.translucent,
                  ),
                ),
                Positioned(
                  left: marker.dx - _markerSize / 2,
                  top: marker.dy - _markerSize / 2,
                  child: const IgnorePointer(child: _AnchorMarker()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _markerSize = 28.0;

class _AnchorMarker extends StatelessWidget {
  const _AnchorMarker();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('autoscroll-anchor'),
      width: _markerSize,
      height: _markerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.onSurfaceVariant, width: 1.5),
      ),
      child: Icon(Icons.open_with, size: 18, color: scheme.onSurfaceVariant),
    );
  }
}

/// A middle-button press that either drags, or is a click nobody else
/// took: a link takes its own middle click.
class _MiddleButtonRecognizer extends OneSequenceGestureRecognizer {
  _MiddleButtonRecognizer()
    : super(supportedDevices: {PointerDeviceKind.mouse});

  ValueChanged<Offset>? onPress;
  ValueChanged<Offset>? onDragStart;
  ValueChanged<Offset>? onDragUpdate;
  VoidCallback? onDragEnd;
  ValueChanged<Offset>? onClick;

  var _origin = Offset.zero;
  var _accepted = false;
  var _moved = false;
  var _dragging = false;
  var _released = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      event.buttons == kTertiaryButton && super.isPointerAllowed(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _origin = event.position;
    _accepted = _moved = _dragging = _released = false;
    onPress?.call(_origin);
  }

  // Alone in its arena it wins at once, so winning is not yet a click.
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_dragging) {
        onDragUpdate?.call(event.position);
      } else if ((event.position - _origin).distance >
          computePanSlop(event.kind, gestureSettings)) {
        _moved = true;
        if (_accepted) {
          _beginDrag();
          onDragUpdate?.call(event.position);
        } else {
          resolve(GestureDisposition.accepted);
        }
      }
    } else if (event is PointerUpEvent) {
      _released = true;
      if (_dragging) {
        onDragEnd?.call();
        stopTrackingPointer(event.pointer);
      } else if (_accepted) {
        stopTrackingPointer(event.pointer);
        onClick?.call(_origin);
      }
    } else if (event is PointerCancelEvent) {
      if (_dragging) onDragEnd?.call();
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  void _beginDrag() {
    _dragging = true;
    onDragStart?.call(_origin);
  }

  @override
  void acceptGesture(int pointer) {
    _accepted = true;
    if (_released) {
      stopTrackingPointer(pointer);
      onClick?.call(_origin);
    } else if (_moved) {
      _beginDrag();
    }
  }

  @override
  void rejectGesture(int pointer) => stopTrackingPointer(pointer);

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'middle button';
}

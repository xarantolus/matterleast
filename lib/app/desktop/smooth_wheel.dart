import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// How quickly a wheel tick's distance is covered: after this long about
/// two thirds of it, after three times as long 95 %.
const wheelGlide = Duration(milliseconds: 55);

/// Pure: the part of [left] to scroll in a frame [elapsed] long, easing out
/// so the motion starts at once and glides to a stop.
Offset wheelStep(Offset left, Duration elapsed) {
  final micros = elapsed.inMicroseconds;
  if (micros <= 0) return Offset.zero;
  final step = left * (1 - math.exp(-micros / wheelGlide.inMicroseconds));
  return (left - step).distance < 0.5 ? left : step;
}

/// Mouse wheel ticks spread over the next frames, the way browsers scroll:
/// each tick adds its distance to what is still to go, and every frame
/// sends on a share of it as an ordinary [PointerScrollEvent] at the
/// pointer. So every scroll view, the PDF viewer and anything else that
/// reads the wheel moves smoothly without its own handling, and lists keep
/// whatever they do with a wheel tick. Trackpads, which scroll with
/// inertia of their own, and Ctrl+wheel zooming are passed on as they are.
class WheelSmoother {
  WheelSmoother(this._send);

  final void Function(PointerEvent event) _send;
  late final _ticker = Ticker(_tick, debugLabel: 'Smooth wheel');
  var _left = Offset.zero;
  var _lastFrame = Duration.zero;
  PointerScrollEvent? _tickEvent;

  /// Takes [event] when it is a wheel tick to smooth; false to handle it as
  /// usual.
  bool take(PointerEvent event) {
    if (event is! PointerScrollEvent ||
        event.kind != PointerDeviceKind.mouse ||
        HardwareKeyboard.instance.isControlPressed) {
      return false;
    }
    _left += event.scrollDelta;
    _tickEvent = event;
    if (!_ticker.isActive) {
      _lastFrame = Duration.zero;
      _ticker.start();
    }
    return true;
  }

  void _tick(Duration elapsed) {
    final step = wheelStep(_left, elapsed - _lastFrame);
    _lastFrame = elapsed;
    _left -= step;
    if (_left == Offset.zero) _ticker.stop();
    if (step == Offset.zero) return;
    final tick = _tickEvent!;
    _send(
      PointerScrollEvent(
        viewId: tick.viewId,
        timeStamp: tick.timeStamp,
        kind: tick.kind,
        device: tick.device,
        position: tick.position,
        scrollDelta: step,
      ),
    );
  }

  void dispose() => _ticker.dispose();
}

/// The binding on desktop: wheel ticks go through [WheelSmoother] before
/// they reach the widgets.
class DesktopBinding extends WidgetsFlutterBinding {
  late final _wheel = WheelSmoother(super.handlePointerEvent);

  @override
  void handlePointerEvent(PointerEvent event) {
    if (!_wheel.take(event)) super.handlePointerEvent(event);
  }
}

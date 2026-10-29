import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The time constant of a wheel tick's ease: a notch is done in about 120 ms.
const wheelGlide = Duration(milliseconds: 22);

/// Pure: the share of [left] to scroll in a frame [elapsed] long.
Offset wheelStep(Offset left, Duration elapsed) {
  final micros = elapsed.inMicroseconds;
  if (micros <= 0) return Offset.zero;
  final step = left * (1 - math.exp(-micros / wheelGlide.inMicroseconds));
  return (left - step).distance < 0.5 ? left : step;
}

/// Spreads mouse wheel ticks over the next frames as ordinary scroll
/// events, so every scroll view glides; trackpads have their own inertia.
class WheelSmoother {
  WheelSmoother(this._send);

  final void Function(PointerEvent event) _send;
  late final _ticker = Ticker(_tick, debugLabel: 'Smooth wheel');
  var _left = Offset.zero;
  var _lastFrame = Duration.zero;
  PointerScrollEvent? _tickEvent;

  /// Whether [event] was taken to be smoothed.
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

/// The desktop binding, with a smoothed wheel.
class DesktopBinding extends WidgetsFlutterBinding {
  late final _wheel = WheelSmoother(super.handlePointerEvent);

  @override
  void handlePointerEvent(PointerEvent event) {
    if (!_wheel.take(event)) super.handlePointerEvent(event);
  }
}

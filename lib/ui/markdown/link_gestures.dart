import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// A tap recognizer for one span of text that also reports a long press
/// and a right click (at its global position). A span takes a single
/// recognizer, so the long press is timed here, from the pointer down like
/// an enclosing message's own long press, and claims the gesture so that
/// one doesn't fire as well. [update] swaps what it calls, so one
/// recognizer lives on across rebuilds of its text.
class TapOrHoldRecognizer extends TapGestureRecognizer {
  TapOrHoldRecognizer() {
    onTapUp = (_) {
      _timer?.cancel();
      if (!_held) _onTapped();
    };
  }

  VoidCallback _onTapped = () {};
  VoidCallback? _onHeld;
  Timer? _timer;
  var _held = false;

  void update({
    required VoidCallback onTapped,
    VoidCallback? onHeld,
    ValueChanged<Offset>? onRightClick,
    VoidCallback? onMiddleClick,
  }) {
    _onTapped = onTapped;
    _onHeld = onHeld;
    onTertiaryTapUp = onMiddleClick == null ? null : (_) => onMiddleClick();
    onSecondaryTapUp = onRightClick == null
        ? null
        : (d) => onRightClick(d.globalPosition);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _held = false;
    _timer?.cancel();
    if (_onHeld == null || event.buttons != kPrimaryButton) return;
    _timer = Timer(kLongPressTimeout, () {
      _held = true;
      resolve(GestureDisposition.accepted);
      _onHeld?.call();
    });
  }

  @override
  void rejectGesture(int pointer) {
    _timer?.cancel();
    super.rejectGesture(pointer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

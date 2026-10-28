import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// A tap recognizer for one span of text that also reports a long press
/// and a right click (at its global position). A span takes a single
/// recognizer, so the long press is timed here. [update] swaps what it
/// calls, so one recognizer lives on across rebuilds of its text.
class TapOrHoldRecognizer extends TapGestureRecognizer {
  TapOrHoldRecognizer() {
    onTapDown = (_) {
      _held = false;
      if (_onHeld == null) return;
      _timer?.cancel();
      _timer = Timer(kLongPressTimeout, () {
        _held = true;
        _onHeld?.call();
      });
    };
    onTapUp = (_) {
      _timer?.cancel();
      if (!_held) _onTapped();
    };
    onTapCancel = () => _timer?.cancel();
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

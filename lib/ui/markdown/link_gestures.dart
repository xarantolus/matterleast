import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// A tap recognizer for one span of text that also reports a long press
/// and a right click (at its global position). A span takes a single
/// recognizer, so the long press is timed here.
class TapOrHoldRecognizer extends TapGestureRecognizer {
  TapOrHoldRecognizer({
    required VoidCallback onTapped,
    VoidCallback? onHeld,
    ValueChanged<Offset>? onRightClick,
  }) {
    if (onRightClick != null) {
      onSecondaryTapUp = (d) => onRightClick(d.globalPosition);
    }
    onTapDown = (_) {
      _held = false;
      if (onHeld == null) return;
      _timer?.cancel();
      _timer = Timer(kLongPressTimeout, () {
        _held = true;
        onHeld();
      });
    };
    onTapUp = (_) {
      _timer?.cancel();
      if (!_held) onTapped();
    };
    onTapCancel = () => _timer?.cancel();
  }

  Timer? _timer;
  var _held = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

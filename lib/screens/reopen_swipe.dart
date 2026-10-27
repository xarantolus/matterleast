import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/conversation_route.dart';

/// A left swipe anywhere on [child] brings back the conversation the user
/// last closed, as Discord does after swiping a chat away.
class ReopenSwipe extends ConsumerStatefulWidget {
  const ReopenSwipe({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReopenSwipe> createState() => _ReopenSwipeState();
}

class _ReopenSwipeState extends ConsumerState<ReopenSwipe> {
  static const _distance = 64.0;

  var _swipe = 0.0;

  void _update(DragUpdateDetails d) {
    final next = _swipe + d.delta.dx;
    if (_swipe > -_distance && next <= -_distance) {
      unawaited(HapticFeedback.mediumImpact());
    }
    _swipe = next;
  }

  void _end(DragEndDetails d) {
    final far = _swipe <= -_distance || d.velocity.pixelsPerSecond.dx < -800;
    _swipe = 0;
    final last = ref.read(lastClosedProvider);
    if (!far || last == null || !mounted) return;
    unawaited(reopenConversation(Navigator.of(context), last));
  }

  @override
  Widget build(BuildContext context) => RawGestureDetector(
    // Empty space between rows and empty states count too.
    behavior: HitTestBehavior.translucent,
    gestures: {
      OneWayDragRecognizer:
          GestureRecognizerFactoryWithHandlers<OneWayDragRecognizer>(
            () => OneWayDragRecognizer(rightward: false, debugOwner: this),
            (r) => r
              ..onStart = (_) {
                _swipe = 0;
              }
              ..onUpdate = _update
              ..onEnd = _end
              ..onCancel = () {
                _swipe = 0;
              },
          ),
    },
    child: widget.child,
  );
}

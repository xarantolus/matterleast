import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/touchpad_swipe.dart';
import 'package:matterleast/screens/root/open_history.dart';

/// A two-finger sideways swipe on a touchpad goes back (left) or forward
/// (right) through the conversations opened, as in a browser. The gesture
/// competes in the arena, so a scrollable or page view under the pointer
/// that can use it keeps it. Only on desktop.
class TouchpadNavigation extends ConsumerWidget {
  const TouchpadNavigation({required this.child, this.onStep, super.key});

  final Widget child;

  /// Replaces the history step, for tests.
  final void Function({required bool forward})? onStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isDesktop) return child;
    return _Swipe(
      onStep:
          onStep ??
          ({required forward}) =>
              unawaited(stepHistory(ref.container, forward: forward)),
      child: child,
    );
  }
}

class _Swipe extends StatefulWidget {
  const _Swipe({required this.onStep, required this.child});

  final void Function({required bool forward}) onStep;
  final Widget child;

  @override
  State<_Swipe> createState() => _SwipeState();
}

class _SwipeState extends State<_Swipe> {
  final _state = ValueNotifier<SwipeState>((forward: null, ratio: 0));
  var _dx = 0.0;

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _reset() {
    _dx = 0;
    _state.value = (forward: null, ratio: 0);
  }

  void _end() {
    final step = swipeStep(_dx);
    _reset();
    if (step != null) widget.onStep(forward: step);
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer
            >(
              () => HorizontalDragGestureRecognizer(
                supportedDevices: {PointerDeviceKind.trackpad},
              ),
              (recognizer) => recognizer
                ..onStart = ((_) => _reset())
                ..onUpdate = ((details) {
                  _dx += details.delta.dx;
                  _state.value = swipeState(_dx);
                })
                ..onEnd = ((_) => _end())
                ..onCancel = _reset,
            ),
      },
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder(
                valueListenable: _state,
                builder: (context, swipe, _) => _Indicator(swipe: swipe),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.swipe});

  final SwipeState swipe;

  @override
  Widget build(BuildContext context) {
    final forward = swipe.forward;
    if (forward == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final ready = swipe.ratio >= 1;
    return Align(
      alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Opacity(
          opacity: 0.35 + 0.65 * swipe.ratio,
          child: Transform.scale(
            scale: 0.5 + 0.5 * swipe.ratio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ready ? scheme.primary : scheme.inverseSurface,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  forward ? Icons.arrow_forward : Icons.arrow_back,
                  color: ready ? scheme.onPrimary : scheme.onInverseSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

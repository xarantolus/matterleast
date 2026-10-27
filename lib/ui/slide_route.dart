import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/motion.dart';

/// A full-screen page, the one route every page but a viewer or a dialog
/// opens in. It slides in from the right over the screen below it. A
/// rightward drag anywhere on it that no inner widget claims, the system
/// back gesture and the back button slide it away again. On desktop it
/// fades in and out instead, Esc closes it and a drag selects text.
class SlideRoute<T> extends PageRoute<T> {
  SlideRoute({required this.builder, this.instant = false, super.settings});

  final WidgetBuilder builder;

  /// Shown at once rather than sliding in.
  final bool instant;

  /// Whether a part of the page slides by itself, as a conversation's
  /// messages do under an app bar that stays in place; otherwise the whole
  /// page slides.
  @protected
  bool get slidesItself => false;

  @override
  TickerFuture didPush() {
    // At once, so keys typed while it slides in don't reach a field below,
    // and that field doesn't take the keyboard back when the page goes.
    FocusManager.instance.primaryFocus?.unfocus();
    if (instant) controller!.value = 1;
    return super.didPush();
  }

  @override
  Duration get transitionDuration {
    final duration = Duration(milliseconds: isDesktop ? 150 : 250);
    final context = navigator?.context;
    return context == null ? duration : motion(context, duration);
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  /// Lets Esc close it through the route's dismiss action.
  @override
  bool get barrierDismissible => isDesktop;

  // The page covers its barrier; a click while it fades must not close it.
  @override
  Widget buildModalBarrier() => const ModalBarrier(dismissible: false);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => isDesktop
      ? FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        )
      : _SlideToPop(
          route: this,
          child: slidesItself ? child : SlidingPart(route: this, child: child),
        );

  Animation<Offset> get _slide =>
      (navigator!.userGestureInProgress
              ? animation!
              : CurvedAnimation(
                  parent: animation!,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ))
          .drive(Tween(begin: const Offset(1, 0), end: Offset.zero));

  void _dragUpdate(double fraction) {
    controller!.value = (controller!.value - fraction).clamp(0.0, 1.0);
  }

  void _dragEnd(double velocity) => _settle(
    pop: velocity > 600 || (velocity > -600 && controller!.value < 0.6),
  );

  @override
  void handleCommitBackGesture() => _settle(pop: true);

  @override
  void handleCancelBackGesture() => _settle(pop: false);

  /// Finishes a drag or a system back gesture from where it left the page.
  void _settle({required bool pop}) {
    if (pop) {
      navigator?.pop();
      if (controller!.isAnimating) {
        controller!.reverse(from: controller!.value);
      }
    } else {
      controller!.forward();
    }
    if (controller!.isAnimating) {
      late final AnimationStatusListener done;
      done = (status) {
        if (status.isAnimating) return;
        navigator?.didStopUserGesture();
        controller!.removeStatusListener(done);
      };
      controller!.addStatusListener(done);
    } else {
      navigator?.didStopUserGesture();
    }
  }
}

/// What slides in a [SlideRoute]: the whole page, or the part of it that
/// [SlideRoute.slidesItself] names.
class SlidingPart extends StatelessWidget {
  const SlidingPart({super.key, required this.route, required this.child});

  final SlideRoute<dynamic> route;
  final Widget child;

  @override
  Widget build(BuildContext context) => isDesktop
      ? child
      : ValueListenableBuilder(
          valueListenable: route.navigator!.userGestureInProgressNotifier,
          builder: (context, _, child) =>
              SlideTransition(position: route._slide, child: child),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 12, color: Color(0x33000000))],
            ),
            child: child,
          ),
        );
}

class _SlideToPop extends StatefulWidget {
  const _SlideToPop({required this.route, required this.child});

  final SlideRoute<dynamic> route;
  final Widget child;

  @override
  State<_SlideToPop> createState() => _SlideToPopState();
}

class _SlideToPopState extends State<_SlideToPop> with WidgetsBindingObserver {
  var _dragging = false;

  bool get _enabled =>
      widget.route.isCurrent &&
      !widget.route.navigator!.userGestureInProgress &&
      widget.route.popGestureEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The system back gesture moves the page with the finger.
  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent || !_enabled) return false;
    widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) => widget
      .route
      .handleUpdateBackGestureProgress(progress: 1 - backEvent.progress);

  @override
  void handleCommitBackGesture() => widget.route.handleCommitBackGesture();

  @override
  void handleCancelBackGesture() => widget.route.handleCancelBackGesture();

  void _end(double velocity) {
    _dragging = false;
    widget.route._dragEnd(velocity);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        OneWayDragRecognizer:
            GestureRecognizerFactoryWithHandlers<OneWayDragRecognizer>(
              () => OneWayDragRecognizer(rightward: true, debugOwner: this),
              (r) => r
                ..onStart = (_) {
                  if (!_enabled) return;
                  _dragging = true;
                  widget.route.navigator?.didStartUserGesture();
                }
                ..onUpdate = (d) {
                  if (_dragging) widget.route._dragUpdate(d.delta.dx / width);
                }
                ..onEnd = (d) {
                  if (_dragging) _end(d.velocity.pixelsPerSecond.dx);
                }
                ..onCancel = () {
                  if (_dragging) _end(0);
                },
            ),
      },
      child: widget.child,
    );
  }
}

/// A horizontal drag that only wins the gesture arena when it moves in one
/// direction and clearly more sideways than up or down.
class OneWayDragRecognizer extends HorizontalDragGestureRecognizer {
  OneWayDragRecognizer({required this.rightward, super.debugOwner});

  final bool rightward;
  Offset? _start;
  var _moved = Offset.zero;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _start = event.position;
    _moved = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && _start != null) {
      _moved = event.position - _start!;
    }
    super.handleEvent(event);
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) =>
      super.hasSufficientGlobalDistanceToAccept(
        pointerDeviceKind,
        deviceTouchSlop,
      ) &&
      (rightward ? _moved.dx > 0 : _moved.dx < 0) &&
      _moved.dx.abs() > 2 * _moved.dy.abs();
}

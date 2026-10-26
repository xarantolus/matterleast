import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';

/// A conversation whose [ConversationPane] slides in from the right over
/// the screen below it, which stays visible, while its app bar stays in
/// place. A rightward drag anywhere on it that no inner widget claims, the
/// system back gesture and the back button slide it away again.
class ConversationRoute<T> extends PageRoute<T> {
  ConversationRoute({
    required this.builder,
    required this.target,
    this.instant = false,
    super.settings,
  });

  final WidgetBuilder builder;

  /// What it shows, so a wider window can move it into a pane.
  final ConversationTarget target;

  /// Shown at once rather than sliding in, as when a narrower window moves
  /// the conversation out of its pane.
  final bool instant;

  @override
  TickerFuture didPush() {
    if (instant) controller!.value = 1;
    return super.didPush();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

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
  ) => _SlideToPop(route: this, child: child);

  Animation<Offset> get _slide =>
      (navigator!.userGestureInProgress
              ? animation!
              : CurvedAnimation(
                  parent: animation!,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ))
          .drive(Tween(begin: const Offset(1, 0), end: Offset.zero));

  void _dragStart() => navigator?.didStartUserGesture();

  void _dragUpdate(double fraction) {
    controller!.value = (controller!.value - fraction).clamp(0.0, 1.0);
  }

  void _dragEnd(double velocity) {
    final pop = velocity > 600 || (velocity > -600 && controller!.value < 0.6);
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

class _SlideToPop extends StatefulWidget {
  const _SlideToPop({required this.route, required this.child});

  final ConversationRoute<dynamic> route;
  final Widget child;

  @override
  State<_SlideToPop> createState() => _SlideToPopState();
}

class _SlideToPopState extends State<_SlideToPop> {
  var _dragging = false;

  bool get _enabled =>
      widget.route.isCurrent &&
      !widget.route.navigator!.userGestureInProgress &&
      widget.route.popGestureEnabled;

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
                  widget.route._dragStart();
                }
                ..onUpdate = (d) {
                  if (_dragging) widget.route._dragUpdate(d.delta.dx / width);
                }
                ..onEnd = (d) {
                  if (!_dragging) return;
                  _dragging = false;
                  widget.route._dragEnd(d.velocity.pixelsPerSecond.dx);
                }
                ..onCancel = () {
                  if (!_dragging) return;
                  _dragging = false;
                  widget.route._dragEnd(0);
                },
            ),
      },
      child: widget.child,
    );
  }
}

/// The part of a conversation below its app bar, which slides in a
/// [ConversationRoute] and is opaque everywhere else. The screen's
/// [Scaffold] must be transparent for the screen below to show.
class ConversationPane extends StatelessWidget {
  const ConversationPane({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
    final route = ModalRoute.of(context);
    if (route is! ConversationRoute) return body;
    return ValueListenableBuilder(
      valueListenable: route.navigator!.userGestureInProgressNotifier,
      builder: (context, _, child) =>
          SlideTransition(position: route._slide, child: child),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 12, color: Color(0x33000000))],
        ),
        child: body,
      ),
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

/// Marks a conversation shown in a pane beside the channel list, with the
/// button that closes it in place of the back button a route would get.
class InPane extends InheritedWidget {
  const InPane({
    super.key,
    required this.onClose,
    required this.closeIcon,
    required this.closeTooltip,
    required super.child,
  });

  final VoidCallback? onClose;
  final IconData closeIcon;
  final String closeTooltip;

  /// The app bar's leading button for a conversation in a pane; null in a
  /// route, which brings its own back button.
  static Widget? closeButton(BuildContext context) {
    final pane = context.dependOnInheritedWidgetOfExactType<InPane>();
    final close = pane?.onClose;
    if (pane == null || close == null) return null;
    return IconButton(
      icon: Icon(pane.closeIcon),
      tooltip: pane.closeTooltip,
      onPressed: close,
    );
  }

  @override
  bool updateShouldNotify(InPane old) =>
      (old.onClose == null) != (onClose == null) ||
      old.closeIcon != closeIcon ||
      old.closeTooltip != closeTooltip;
}

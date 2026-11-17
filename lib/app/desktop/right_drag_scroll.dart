import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

const _touchDevice = 0x7d5c0000;
const _touchPointer = 0x7d5c0001;

/// Holding the right button and moving scrolls whatever scroll view is
/// under the pointer, and letting go mid-move flings it, as a finger does.
/// A right click that stays put is not taken and opens menus as usual.
///
/// Past the touch slop the drag is replayed as a touch stream from the
/// press point, so the scroll view's own drag, velocity and physics apply.
class RightDragScroll extends StatelessWidget {
  const RightDragScroll({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => RawGestureDetector(
    behavior: HitTestBehavior.translucent,
    gestures: {
      _RightDragRecognizer:
          GestureRecognizerFactoryWithHandlers<_RightDragRecognizer>(
            _RightDragRecognizer.new,
            (_) {},
          ),
    },
    child: child,
  );
}

class _RightDragRecognizer extends OneSequenceGestureRecognizer {
  _RightDragRecognizer() : super(supportedDevices: {PointerDeviceKind.mouse});

  var _origin = Offset.zero;
  var _replaying = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      event.buttons == kSecondaryButton && super.isPointerAllowed(event);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _origin = event.position;
    _replaying = false;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_replaying) {
        _send(
          event,
          (e) => PointerMoveEvent(
            viewId: e.viewId,
            timeStamp: e.timeStamp,
            kind: PointerDeviceKind.touch,
            device: _touchDevice,
            pointer: _touchPointer,
            position: e.position,
            delta: e.delta,
            buttons: kPrimaryButton,
          ),
        );
      } else if ((event.position - _origin).distance >
          computeHitSlop(PointerDeviceKind.touch, gestureSettings)) {
        _replaying = true;
        resolve(GestureDisposition.accepted);
        _send(
          event,
          (e) => PointerDownEvent(
            viewId: e.viewId,
            timeStamp: e.timeStamp,
            kind: PointerDeviceKind.touch,
            device: _touchDevice,
            pointer: _touchPointer,
            position: _origin,
            buttons: kPrimaryButton,
          ),
        );
        _send(
          event,
          (e) => PointerMoveEvent(
            viewId: e.viewId,
            timeStamp: e.timeStamp,
            kind: PointerDeviceKind.touch,
            device: _touchDevice,
            pointer: _touchPointer,
            position: e.position,
            delta: e.position - _origin,
            buttons: kPrimaryButton,
          ),
        );
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (_replaying) {
        _replaying = false;
        _send(
          event,
          (e) => event is PointerUpEvent
              ? PointerUpEvent(
                  viewId: e.viewId,
                  timeStamp: e.timeStamp,
                  kind: PointerDeviceKind.touch,
                  device: _touchDevice,
                  pointer: _touchPointer,
                  position: e.position,
                )
              : PointerCancelEvent(
                  viewId: e.viewId,
                  timeStamp: e.timeStamp,
                  kind: PointerDeviceKind.touch,
                  device: _touchDevice,
                  pointer: _touchPointer,
                  position: e.position,
                ),
        );
      } else {
        resolve(GestureDisposition.rejected);
      }
      stopTrackingPointer(event.pointer);
    }
  }

  void _send(PointerEvent from, PointerEvent Function(PointerEvent) make) =>
      GestureBinding.instance.handlePointerEvent(make(from));

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) => stopTrackingPointer(pointer);

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'right-button drag scroll';
}

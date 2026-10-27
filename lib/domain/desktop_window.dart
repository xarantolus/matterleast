import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'desktop_window.freezed.dart';
part 'desktop_window.g.dart';

/// The smallest desktop window. At this width the layout always shows the
/// wide panes, never the phone layout.
const minimumWindowSize = Size(940, 500);

const defaultWindowSize = Size(1280, 800);

/// Where the desktop window was, in logical pixels, restored at launch.
/// [x] and [y] are null when only the size is known.
@freezed
abstract class WindowPlacement with _$WindowPlacement {
  const factory WindowPlacement({
    double? x,
    double? y,
    required double width,
    required double height,
    @Default(false) bool maximized,
  }) = _WindowPlacement;

  factory WindowPlacement.fromJson(Map<String, Object?> json) =>
      _$WindowPlacementFromJson(json);
}

/// How much of a window must lie on a display for its position to count.
const _visiblePart = 64.0;

/// Pure: [saved] made fit for the displays at hand: at least the minimum
/// size, at most the largest display, and without a position (so the
/// window centres) when too little of it would land on any display, such
/// as after a monitor was unplugged.
WindowPlacement placementOnScreen(WindowPlacement saved, List<Rect> displays) {
  final largest = displays.fold(
    Size.zero,
    (size, d) => Size(
      size.width > d.width ? size.width : d.width,
      size.height > d.height ? size.height : d.height,
    ),
  );
  double fit(double value, double minimum, double maximum) =>
      value.clamp(minimum, maximum < minimum ? minimum : maximum);
  final width = fit(
    saved.width,
    minimumWindowSize.width,
    displays.isEmpty ? saved.width : largest.width,
  );
  final height = fit(
    saved.height,
    minimumWindowSize.height,
    displays.isEmpty ? saved.height : largest.height,
  );
  final x = saved.x;
  final y = saved.y;
  final onScreen =
      x != null &&
      y != null &&
      displays.any((d) {
        final overlap = d.intersect(Rect.fromLTWH(x, y, width, height));
        return overlap.width >= _visiblePart && overlap.height >= _visiblePart;
      });
  return WindowPlacement(
    x: onScreen ? x : null,
    y: onScreen ? y : null,
    width: width,
    height: height,
    maximized: saved.maximized,
  );
}

/// Pure: what to remember after the window moved, resized or (un)maximised.
/// A maximised window keeps the bounds it had before, which it returns to
/// when unmaximised after the next launch.
WindowPlacement placementAfterChange(
  WindowPlacement? previous, {
  required Rect bounds,
  required bool maximized,
}) => maximized
    ? (previous ??
              WindowPlacement(
                width: defaultWindowSize.width,
                height: defaultWindowSize.height,
              ))
          .copyWith(maximized: true)
    : WindowPlacement(
        x: bounds.left,
        y: bounds.top,
        width: bounds.width,
        height: bounds.height,
      );

enum CloseAction {
  /// Into the tray; the app keeps running and notifying.
  hide,

  /// To the taskbar or dock, where no tray would show the app again.
  minimize,
  quit,
}

/// Pure: what closing the window does. Hiding needs a tray to come back
/// from; without one the window only minimises, so it can't get lost.
CloseAction closeAction({required bool closeToTray, required bool hasTray}) =>
    !closeToTray
    ? CloseAction.quit
    : hasTray
    ? CloseAction.hide
    : CloseAction.minimize;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/tokens.dart';

/// A modal bottom sheet, the way every sheet opens. The keyboard goes down
/// while it shows; when it closes, the field that had the keyboard takes
/// it back, unless the sheet led to another page.
///
/// On desktop the same content opens as a popup instead: next to [anchor]
/// (a global rect, such as the button or the point clicked) when given,
/// else as a dialog in the middle of the window. Esc and a click outside
/// close it.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool showDragHandle = true,
  BoxConstraints? constraints,
  Rect? anchor,
}) async {
  final focused = FocusManager.instance.primaryFocus;
  final restore = focused is! FocusScopeNode ? focused : null;
  // Unfocused rather than left to the route, so nothing below takes the
  // focus back on its own once a page opened from the sheet closes.
  restore?.unfocus();
  final picked = isDesktop
      ? await _showPopup<T>(context, builder, constraints, anchor)
      : await showModalBottomSheet<T>(
          context: context,
          builder: builder,
          isScrollControlled: isScrollControlled,
          useSafeArea: useSafeArea,
          showDragHandle: showDragHandle,
          constraints: constraints,
        );
  if (restore != null &&
      context.mounted &&
      (ModalRoute.of(context)?.isCurrent ?? true) &&
      restore.context != null &&
      restore.canRequestFocus) {
    restore.requestFocus();
  }
  return picked;
}

/// The global rect of [context]'s widget, for anchoring a popup to it.
Rect? globalRectOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Popups next to what opened them are as narrow as a menu; dialogs as
/// wide as Material's widest.
const _anchoredWidth = 360.0;
const _dialogWidth = 560.0;

Future<T?> _showPopup<T>(
  BuildContext context,
  WidgetBuilder builder,
  BoxConstraints? constraints,
  Rect? anchor,
) => showDialog<T>(
  context: context,
  barrierColor: anchor == null ? null : Colors.transparent,
  // Anchored ones are placed in window coordinates.
  useSafeArea: anchor == null,
  builder: (dialog) {
    final limits = BoxConstraints(
      maxWidth: anchor == null ? _dialogWidth : _anchoredWidth,
      maxHeight: MediaQuery.sizeOf(dialog).height * 0.8,
    );
    final content = ConstrainedBox(
      constraints: constraints?.enforce(limits) ?? limits,
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
        child: Builder(builder: builder),
      ),
    );
    if (anchor == null) {
      return Dialog(clipBehavior: Clip.antiAlias, child: content);
    }
    return CustomSingleChildLayout(
      delegate: AnchoredLayout(anchor),
      child: Material(
        type: MaterialType.card,
        elevation: 3,
        color: Theme.of(dialog).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  },
);

/// Places a popup under [anchor], or above it where there is no room
/// below, starting at its left edge and kept inside the window.
class AnchoredLayout extends SingleChildLayoutDelegate {
  const AnchoredLayout(this.anchor);

  final Rect anchor;

  static const _margin = Spacing.sm;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(const EdgeInsets.all(_margin));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double fit(double start, double extent, double room) =>
        math.max(_margin, math.min(start, room - extent - _margin));

    final x = fit(anchor.left, childSize.width, size.width);
    final below = anchor.bottom + childSize.height <= size.height - _margin;
    final above = anchor.top - childSize.height >= _margin;
    final y = below || !above ? anchor.bottom : anchor.top - childSize.height;
    return Offset(x, fit(y, childSize.height, size.height));
  }

  @override
  bool shouldRelayout(AnchoredLayout oldDelegate) =>
      anchor != oldDelegate.anchor;
}

import 'package:material_ui/material_ui.dart';

/// A modal bottom sheet, the way every sheet opens. The keyboard goes down
/// while it shows; when it closes, the field that had the keyboard takes
/// it back, unless the sheet led to another page.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool showDragHandle = true,
  BoxConstraints? constraints,
}) async {
  final focused = FocusManager.instance.primaryFocus;
  final restore = focused is! FocusScopeNode ? focused : null;
  // Unfocused rather than left to the route, so nothing below takes the
  // focus back on its own once a page opened from the sheet closes.
  restore?.unfocus();
  final picked = await showModalBottomSheet<T>(
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

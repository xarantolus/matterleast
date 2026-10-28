import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/ui/slide_route.dart';

/// A conversation's [SlideRoute], which knows what it shows.
class ConversationRoute<T> extends SlideRoute<T> {
  ConversationRoute({
    required super.builder,
    required this.target,
    super.instant,
    super.settings,
  });

  /// What it shows, so a wider window can move it into a pane.
  final ConversationTarget target;
}

/// Marks a conversation shown in a pane beside the channel list, with the
/// button that closes it in place of the back button a route would get.
class InPane extends InheritedWidget {
  const InPane({
    super.key,
    required this.onClose,
    required this.closeIcon,
    required this.closeTooltip,
    this.closeAtEnd = false,
    required super.child,
  });

  final VoidCallback? onClose;
  final IconData closeIcon;
  final String closeTooltip;

  /// A side pane closes at the end of its header; a main pane goes back
  /// from the start, like a route.
  final bool closeAtEnd;

  /// The app bar's leading button for a conversation in a pane; null in a
  /// route, which brings its own back button, and in a side pane.
  static Widget? closeButton(BuildContext context) =>
      _button(context, atEnd: false);

  /// The button at the end of a side pane's app bar.
  static Widget? endButton(BuildContext context) =>
      _button(context, atEnd: true);

  static Widget? _button(BuildContext context, {required bool atEnd}) {
    final pane = context.dependOnInheritedWidgetOfExactType<InPane>();
    final close = pane?.onClose;
    if (pane == null || close == null || pane.closeAtEnd != atEnd) return null;
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
      old.closeAtEnd != closeAtEnd ||
      old.closeTooltip != closeTooltip;
}

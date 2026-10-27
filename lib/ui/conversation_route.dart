import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/ui/slide_route.dart';

/// A conversation whose [ConversationPane] slides in from the right over
/// the screen below it, which stays visible, while its app bar stays in
/// place; it goes back like any [SlideRoute].
class ConversationRoute<T> extends SlideRoute<T> {
  ConversationRoute({
    required super.builder,
    required this.target,
    super.instant,
    super.settings,
  });

  /// What it shows, so a wider window can move it into a pane.
  final ConversationTarget target;

  @override
  bool get slidesItself => true;
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
    return SlidingPart(route: route, child: body);
  }
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

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/focus_region.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/slide_route.dart';

/// Text in a toolbar grows with the system font size only this far, as
/// Android's own toolbars do; the bar grows with it.
const _maxBarTextScale = 1.3;

/// A page under the one shared header: the channel list, a conversation
/// and every content view. The page gives the header its [title],
/// [subtitle], [leading], [actions] and whether it is [progress]ing; the
/// header is the same height on every page. In a [SlideRoute] the
/// header stays in place and fades over from the page below while only
/// [body] slides; in a pane the header shows the pane's close button.
class ContentPage extends StatelessWidget {
  const ContentPage({
    required this.title,
    required this.body,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.progress = false,
    this.progressDelay = Duration.zero,
    this.focusRegion = true,
    this.backgroundColor,
    super.key,
  });

  final Widget title;

  /// A quiet line under the title.
  final String? subtitle;

  /// In place of the back or close button the header picks itself.
  final Widget? leading;
  final List<Widget> actions;

  /// The slim bar under the toolbar runs, after [progressDelay].
  final bool progress;
  final Duration progressDelay;
  final Widget body;

  /// The body is one region for F6; false when it holds regions of its own.
  final bool focusRegion;

  /// The body's colour, the page's by default.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: _maxBarTextScale)
        .scale(1);
    final height =
        (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight) * scale;
    final slot = ProgressSlot(active: progress, delay: progressDelay);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height + slot.preferredSize.height),
        child: _Header(
          toolbarHeight: height,
          title: title,
          subtitle: subtitle,
          leading: leading,
          actions: actions,
          bottom: slot,
        ),
      ),
      body: SlidingBody(child: focusRegion ? FocusRegion(child: body) : body),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.toolbarHeight,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.actions,
    required this.bottom,
  });

  final double toolbarHeight;
  final Widget title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final ProgressSlot bottom;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    // The bar stays; what it shows fades in with a page sliding in, out
    // while a page slides in over it, and back as that page goes. The bar
    // stays opaque, so a taller header never shows the page below through
    // it. On desktop the whole page fades already.
    final next = route?.secondaryAnimation;
    final leaving = next == null ? null : ReverseAnimation(next);
    final arriving = route is SlideRoute && !route.wholePage && !isDesktop
        ? route.animation
        : null;
    Widget fade(Widget child) {
      var faded = child;
      for (final opacity in [?leaving, ?arriving]) {
        faded = FadeTransition(opacity: opacity, child: faded);
      }
      return faded;
    }

    // A popout's first page closes with the popout's own button.
    final popout = context.getInheritedWidgetOfExactType<InPopout>();
    final leading =
        this.leading ??
        InPane.closeButton(context) ??
        ((route?.impliesAppBarDismissal ?? false) &&
                !(popout != null && route!.isFirst)
            ? const BackButton()
            : null);
    final subtitle = this.subtitle;
    return AppBar(
      automaticallyImplyLeading: false,
      primary: popout == null,
      toolbarHeight: toolbarHeight,
      leading: leading == null ? null : fade(leading),
      title: fade(
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: _maxBarTextScale,
          child: subtitle == null
              ? title
              : _TitleWithSubtitle(title: title, subtitle: subtitle),
        ),
      ),
      actions: [
        for (final action in actions) fade(action),
        if (popout != null)
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: popout.onClose,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: bottom.preferredSize,
        child: fade(bottom),
      ),
    );
  }
}

class _TitleWithSubtitle extends StatelessWidget {
  const _TitleWithSubtitle({required this.title, required this.subtitle});

  final Widget title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      title,
      Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor),
      ),
    ],
  );
}

/// Marks the pages inside a desktop popout, which [onClose] closes.
class InPopout extends InheritedWidget {
  const InPopout({required this.onClose, required super.child, super.key});

  final VoidCallback onClose;

  /// Whether [context] is inside a popout.
  static bool contains(BuildContext context) =>
      context.getInheritedWidgetOfExactType<InPopout>() != null;

  @override
  bool updateShouldNotify(InPopout old) => false;
}

/// The part of a page below its header: opaque, the Material its rows ink
/// on, and in a content [SlideRoute] the part that slides. The page's
/// [Scaffold] must be transparent for the page below to show while it
/// slides.
class SlidingBody extends StatelessWidget {
  const SlidingBody({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: color ?? Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
    final route = ModalRoute.of(context);
    if (route is! SlideRoute || route.wholePage) return body;
    return SlidingPart(route: route, child: body);
  }
}

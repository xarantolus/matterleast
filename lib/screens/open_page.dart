import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/slide_route.dart';

/// Opens [page], a [ContentPage], the one way every screen opens one: in
/// the conversation pane on a wide window, over what shows on a narrow
/// one, and inside the popout it was opened from. With [popout] it opens
/// in a card over the window on desktop instead, where whatever it opens
/// stays inside the card. Completes once it closes.
Future<void> openPage(
  NavigatorState navigator,
  Widget page, {
  bool popout = false,
}) async {
  if (!navigator.mounted) return;
  if (InPopout.contains(navigator.context)) {
    await navigator.push(SlideRoute<void>(builder: (_) => page));
    return;
  }
  if (popout && isDesktop) {
    return showDialog<void>(
      context: navigator.context,
      builder: (_) => _Popout(page: page),
    );
  }
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  final pane = container.read(paneRoutesProvider).navigator;
  final target = pane != null && pane.mounted ? pane : navigator;
  await target.push(SlideRoute<void>(builder: (_) => page));
}

/// Popouts are as wide as a comfortable form and leave the window's edges
/// in view.
const _popoutWidth = 640.0;

/// A card in the middle of the window, as the profile card opens, with its
/// own navigator so the pages it leads to open inside it. Esc and a click
/// outside close it; Back goes back inside it first.
class _Popout extends StatefulWidget {
  const _Popout({required this.page});

  final Widget page;

  @override
  State<_Popout> createState() => _PopoutState();
}

class _PopoutState extends State<_Popout> {
  final _inside = NavigatorObserver();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final card = theme.colorScheme.surfaceContainerHigh;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: card,
      child: SizedBox(
        width: math.min(_popoutWidth, size.width * 0.9),
        height: size.height * 0.8,
        child: Theme(
          // The pages' headers sit on the card, not on the app's bar.
          data: theme.copyWith(
            scaffoldBackgroundColor: card,
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: card,
              foregroundColor: theme.colorScheme.onSurface,
              titleTextStyle: theme.textTheme.titleLarge,
            ),
          ),
          child: InPopout(
            onClose: () => Navigator.of(context).pop(),
            child: NavigatorPopHandler(
              onPopWithResult: (_) => _inside.navigator?.maybePop(),
              child: FocusTraversalGroup(
                child: Navigator(
                  observers: [_inside],
                  onGenerateInitialRoutes: (_, _) => [
                    _FirstInPopout(
                      builder: (_) => widget.page,
                      close: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The page a popout opens on. Closing it closes the popout, so a page
/// that closes itself when done works the same in a popout.
class _FirstInPopout extends MaterialPageRoute<void> {
  _FirstInPopout({required super.builder, required this.close});

  final VoidCallback close;

  /// Lets Esc on the page close the popout; the page covers its barrier.
  @override
  bool get barrierDismissible => true;

  @override
  void install() {
    super.install();
    addLocalHistoryEntry(LocalHistoryEntry(onRemove: close));
  }
}

/// The navigator to open a conversation on from a page on [navigator]:
/// the one under the popout the page is in, which closes first.
NavigatorState outsidePopout(NavigatorState navigator) {
  if (!InPopout.contains(navigator.context)) return navigator;
  final popout = ModalRoute.of(navigator.context);
  final outer = popout?.navigator;
  if (popout == null || outer == null) return navigator;
  if (popout.isCurrent) {
    outer.pop();
  } else if (popout.isActive) {
    outer.removeRoute(popout);
  }
  return outer;
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/channel/reading_places.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/resizable_panes.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/empty_state.dart';

/// The rail and channel list ([list]) alone on a narrow window, where
/// conversations and content views are routes over it, or with the open
/// conversation (and on a large window its thread) beside it on a wide
/// one, where content views open over the conversation in its pane. A
/// window that crosses the line moves what is open between routes and
/// panes and keeps where conversations were read.
class PaneLayout extends ConsumerStatefulWidget {
  const PaneLayout({required this.list, super.key});

  final Widget list;

  @override
  ConsumerState<PaneLayout> createState() => _PaneLayoutState();
}

class _PaneLayoutState extends ConsumerState<PaneLayout> {
  late final ConversationRoutes _routes;
  late final ConversationRoutes _paneRoutes;
  late final StreamSubscription<void> _routesChanged;
  late final StreamSubscription<void> _paneRoutesChanged;
  bool? _wasWide;
  var _moveScheduled = false;

  @override
  void initState() {
    super.initState();
    _routes = ref.read(conversationRoutesProvider);
    _routesChanged = _routes.changes.listen((_) => _changed());
    _paneRoutes = ref.read(paneRoutesProvider);
    _paneRoutesChanged = _paneRoutes.changes.listen((_) => _changed());
  }

  @override
  void dispose() {
    unawaited(_routesChanged.cancel());
    unawaited(_paneRoutesChanged.cancel());
    _paneRoutes.takeAll();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _afterFrame(void Function() move) {
    if (_moveScheduled) return;
    _moveScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveScheduled = false;
      if (mounted) move();
    });
  }

  /// Routes into panes: the window became wide. The content views over
  /// the top conversation open over it in its pane; the ones under it give
  /// way, as opening a conversation in a pane closes them.
  void _intoPanes() {
    final stack = _routes.stack;
    if (stack.isEmpty) return;
    final live = _routes.live;
    ref.read(readingPlacesProvider).captureAll();
    if (live.isNotEmpty) {
      ref
          .read(openPanesProvider.notifier)
          .set(Panes.fromStack([for (final r in live) r.target]));
    }
    final over = stack.sublist(stack.lastIndexWhere(live.contains) + 1);
    final navigator = Navigator.of(context);
    for (final route in stack.reversed) {
      navigator.removeRoute(route);
    }
    final pane = _paneRoutes.navigator;
    for (final route in over) {
      pane?.push(reopened(route, instant: true)()).ignore();
    }
  }

  /// Panes into routes: the window became narrow.
  void _intoRoutes() {
    final panes = ref.read(openPanesProvider);
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final over = _paneRoutes.takeAll();
    if (panes.isEmpty && over.isEmpty) return;
    ref.read(readingPlacesProvider).captureAll();
    ref.read(openPanesProvider.notifier).set(Panes.none);
    final navigator = Navigator.of(context);
    for (final target in panes.stack) {
      navigator.push(conversationRoute(target, instant: true)).ignore();
    }
    for (final route in over) {
      navigator.push(reopened(route, instant: true)()).ignore();
    }
  }

  // Sibling Scaffolds each show the snack bar; one around them all shows
  // it once.
  @override
  Widget build(BuildContext context) =>
      Scaffold(resizeToAvoidBottomInset: false, body: _layout(context));

  Widget _layout(BuildContext context) {
    final windowClass = windowClassOf(MediaQuery.sizeOf(context).width);
    final wide = windowClass.showsPanes;
    if (_wasWide != null && _wasWide != wide) {
      // Before the views below rebuild for the new size and lose their
      // place.
      ref.read(readingPlacesProvider).captureAll();
    }
    _wasWide = wide;
    final panes = ref.watch(openPanesProvider);
    final routesOpen = _routes.stack.isNotEmpty;
    final contentOpen = _paneRoutes.stack.isNotEmpty;
    if (!wide) {
      if (!panes.isEmpty || contentOpen) _afterFrame(_intoRoutes);
      // The conversation stays on screen until its route covers it.
      return Stack(
        children: [
          widget.list,
          if (panes.shownIn(windowClass).main case final main?)
            Positioned.fill(child: _pane(main)),
        ],
      );
    }
    if (routesOpen) _afterFrame(_intoPanes);
    final shown = routesOpen
        ? (main: null, side: null)
        : panes.shownIn(windowClass);
    final notifier = ref.read(openPanesProvider.notifier);
    final padding = MediaQuery.paddingOf(context);
    final side = shown.side;
    return PopScope(
      canPop: panes.isEmpty && !contentOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final pane = _paneRoutes.navigator;
        if (contentOpen && pane != null) {
          unawaited(pane.maybePop());
        } else {
          notifier.back();
        }
      },
      child: ResizablePanes(
        defaultListWidth: listPaneWidth(windowClass),
        listInset: railWidth + 1 + padding.left,
        sideInset: padding.right,
        list: MediaQuery.removePadding(
          context: context,
          removeRight: true,
          child: widget.list,
        ),
        main: MediaQuery.removePadding(
          context: context,
          removeLeft: true,
          removeRight: side != null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Out of F6 and Tab while a content view covers it.
              ExcludeFocus(
                excluding: contentOpen,
                child: switch (shown.main) {
                  final main? => InPane(
                    onClose: main is ThreadTarget ? notifier.back : null,
                    closeIcon: Icons.arrow_back,
                    closeTooltip: 'Back to the channel',
                    child: _pane(main),
                  ),
                  null => const _NothingOpen(),
                },
              ),
              // Outside the conversation's own route, so its pictures still
              // fly into the gallery.
              Offstage(
                offstage: !contentOpen,
                child: ClipRect(
                  child: Navigator(
                    observers: [_paneRoutes],
                    onGenerateInitialRoutes: (_, _) => [_emptyRoute()],
                  ),
                ),
              ),
            ],
          ),
        ),
        side: side == null
            ? null
            : MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: InPane(
                  onClose: notifier.back,
                  closeIcon: Icons.close,
                  closeTooltip: 'Close the thread',
                  child: _pane(side),
                ),
              ),
      ),
    );
  }

  Widget _pane(ConversationTarget target) =>
      KeyedSubtree(key: ValueKey(target), child: conversationScreen(target));
}

/// What the pane's navigator shows under its content views: nothing, so
/// the conversation shows through while one slides.
Route<void> _emptyRoute() => PageRouteBuilder<void>(
  opaque: false,
  pageBuilder: (_, _, _) => const SizedBox.shrink(),
);

class _NothingOpen extends StatelessWidget {
  const _NothingOpen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: EmptyState(
      icon: Icons.forum_outlined,
      title: 'No conversation open',
      body: 'Pick a channel or a direct message from the list.',
    ),
  );
}

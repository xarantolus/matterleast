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
/// conversations are routes over it, or with the open conversation (and on
/// a large window its thread) beside it on a wide one. A window that
/// crosses the line moves the open conversations between routes and panes
/// and keeps where they were read.
class PaneLayout extends ConsumerStatefulWidget {
  const PaneLayout({required this.list, super.key});

  final Widget list;

  @override
  ConsumerState<PaneLayout> createState() => _PaneLayoutState();
}

class _PaneLayoutState extends ConsumerState<PaneLayout> {
  late final ConversationRoutes _routes;
  late final StreamSubscription<void> _routesChanged;
  bool? _wasWide;
  var _moveScheduled = false;

  @override
  void initState() {
    super.initState();
    _routes = ref.read(conversationRoutesProvider);
    _routesChanged = _routes.changes.listen((_) => _changed());
  }

  @override
  void dispose() {
    unawaited(_routesChanged.cancel());
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

  /// Routes into panes: the window became wide.
  void _intoPanes() {
    final live = _routes.live;
    if (live.isEmpty) return;
    ref.read(readingPlacesProvider).captureAll();
    ref
        .read(openPanesProvider.notifier)
        .set(Panes.fromStack([for (final r in live) r.target]));
    final navigator = Navigator.of(context);
    for (final route in live.reversed) {
      navigator.removeRoute(route);
    }
  }

  /// Panes into routes: the window became narrow.
  void _intoRoutes() {
    final panes = ref.read(openPanesProvider);
    if (panes.isEmpty || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    ref.read(readingPlacesProvider).captureAll();
    ref.read(openPanesProvider.notifier).set(Panes.none);
    final navigator = Navigator.of(context);
    for (final target in panes.stack) {
      navigator.push(conversationRoute(target, instant: true)).ignore();
    }
  }

  // The list and every pane are Scaffolds side by side, and each one that
  // isn't inside another shows the app's snack bars. This one holds them all
  // so a snack bar shows once per window.
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
    final routesOpen = _routes.live.isNotEmpty;
    if (!wide) {
      if (!panes.isEmpty) _afterFrame(_intoRoutes);
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
      canPop: panes.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.back();
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

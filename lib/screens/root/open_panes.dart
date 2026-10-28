import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_panes.g.dart';

/// The conversations shown beside the channel list on a wide screen. On a
/// narrow one the [ConversationRoute]s on the navigator are the truth.
@Riverpod(keepAlive: true)
class OpenPanes extends _$OpenPanes {
  @override
  Panes build() => Panes.none;

  void open(ConversationTarget target) {
    ref.read(forwardHistoryProvider).opened();
    state = state.open(target);
  }

  /// Closes the thread, or else the channel; Forward opens it again.
  void back() {
    final before = state;
    if (before.isEmpty) return;
    state = before.back();
    ref.read(forwardHistoryProvider).closed(() => state = before);
  }

  void close(String url, String channelId) =>
      state = state.without(url, channelId);

  void set(Panes panes) => state = panes;
}

/// The conversation the user last closed on a narrow screen; a left swipe
/// on the channel list or Home brings it back.
@Riverpod(keepAlive: true)
class LastClosed extends _$LastClosed {
  @override
  ConversationTarget? build() => null;

  void set(ConversationTarget target) => state = target;
}

/// The conversation routes and content views on the app's navigator,
/// oldest first.
@Riverpod(keepAlive: true)
ConversationRoutes conversationRoutes(Ref ref) {
  final routes = ConversationRoutes(ref.watch(forwardHistoryProvider));
  ref.onDispose(routes.close);
  return routes;
}

/// The content views open in the conversation pane of a wide window, over
/// the conversation; their navigator is there only while the window is
/// wide.
@Riverpod(keepAlive: true)
ConversationRoutes paneRoutes(Ref ref) {
  final routes = ConversationRoutes(ref.watch(forwardHistoryProvider));
  ref.onDispose(routes.close);
  return routes;
}

/// What Back closed, most recent last, for Forward to open again. Opening
/// anything else forgets it, as a browser does.
@Riverpod(keepAlive: true)
ForwardHistory forwardHistory(Ref ref) => ForwardHistory();

class ForwardHistory {
  final _closed = <VoidCallback>[];
  var _reopening = false;

  void closed(VoidCallback reopen) => _closed.add(reopen);

  void opened() {
    if (!_reopening) _closed.clear();
  }

  /// Opens what Back closed last.
  void forward() {
    if (_closed.isEmpty) return;
    _reopening = true;
    try {
      _closed.removeLast()();
    } finally {
      _reopening = false;
    }
  }
}

/// Keeps track of the [SlideRoute]s of one navigator.
class ConversationRoutes extends NavigatorObserver {
  ConversationRoutes(this._history);

  final ForwardHistory _history;
  final _stack = <SlideRoute<dynamic>>[];
  final _changes = StreamController<void>.broadcast();

  /// Fires after the routes changed.
  Stream<void> get changes => _changes.stream;

  void close() => unawaited(_changes.close());

  /// The conversation routes, oldest first.
  List<ConversationRoute<dynamic>> get live =>
      List.unmodifiable(_stack.whereType<ConversationRoute<dynamic>>());

  /// The conversations and content views, oldest first.
  List<SlideRoute<dynamic>> get stack => List.unmodifiable(_stack);

  /// Hands over the routes of a navigator that went away, to open them
  /// again elsewhere.
  List<SlideRoute<dynamic>> takeAll() {
    final all = List.of(_stack);
    _stack.clear();
    return all;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is SlideRoute) _history.opened();
    _add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final navigator = this.navigator;
    if (navigator != null && route is SlideRoute && _stack.contains(route)) {
      final again = reopened(route);
      _history.closed(() {
        if (navigator.mounted) unawaited(navigator.push(again()));
      });
    }
    _remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _remove(oldRoute);
    if (newRoute != null) _add(newRoute);
  }

  void _add(Route<dynamic> route) {
    if (route is! SlideRoute || route.wholePage) return;
    _stack.add(route);
    _changed();
  }

  void _remove(Route<dynamic> route) {
    if (_stack.remove(route)) _changed();
  }

  // Navigator calls in while it rebuilds; listeners hear of it after.
  void _changed() => scheduleMicrotask(() {
    if (!_changes.isClosed) _changes.add(null);
  });
}

/// A new route that shows what [route] showed, at once when [instant].
Route<void> Function() reopened(
  SlideRoute<dynamic> route, {
  bool instant = false,
}) => switch (route) {
  ConversationRoute(:final target, :final builder) =>
    () => ConversationRoute<void>(
      target: target,
      builder: builder,
      instant: instant,
    ),
  SlideRoute(:final builder) => () => SlideRoute<void>(
    builder: builder,
    instant: instant,
  ),
};

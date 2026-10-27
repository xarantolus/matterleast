import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_panes.g.dart';

/// The conversations shown beside the channel list on a wide screen. On a
/// narrow one the [ConversationRoute]s on the navigator are the truth.
@Riverpod(keepAlive: true)
class OpenPanes extends _$OpenPanes {
  @override
  Panes build() => Panes.none;

  void open(ConversationTarget target) => state = state.open(target);

  void back() => state = state.back();

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

/// The conversation routes on the app's navigator, oldest first.
@Riverpod(keepAlive: true)
ConversationRoutes conversationRoutes(Ref ref) {
  final routes = ConversationRoutes();
  ref.onDispose(routes.close);
  return routes;
}

class ConversationRoutes extends NavigatorObserver {
  final _live = <ConversationRoute<dynamic>>[];
  final _changes = StreamController<void>.broadcast();

  /// Fires after the routes changed.
  Stream<void> get changes => _changes.stream;

  void close() => unawaited(_changes.close());

  List<ConversationRoute<dynamic>> get live => List.unmodifiable(_live);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _remove(oldRoute);
    if (newRoute != null) _add(newRoute);
  }

  void _add(Route<dynamic> route) {
    if (route is! ConversationRoute) return;
    _live.add(route);
    _changed();
  }

  void _remove(Route<dynamic> route) {
    if (_live.remove(route)) _changed();
  }

  // Navigator calls in while it rebuilds; listeners hear of it after.
  void _changed() => scheduleMicrotask(() {
    if (!_changes.isClosed) _changes.add(null);
  });
}

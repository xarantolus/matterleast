import 'dart:async';

import 'package:matterleast/api/websocket/server_events.dart';

/// Runs a server's notification check shortly after its live connection
/// stored a new post or caught up after a gap. Used by the stay-connected
/// service on Android and by the window on desktop.
class LiveNotifications {
  LiveNotifications({
    required this._applied,
    required this._caughtUp,
    required this._check,
    this.delay = const Duration(seconds: 2),
  });

  final Stream<ServerEvent> _applied;
  final Stream<void> _caughtUp;
  final Future<void> Function() _check;

  /// Posts often come in bursts; one check covers them.
  final Duration delay;

  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _debounce;

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(_applied.where((e) => e is PostedEvent).listen((_) => _soon()))
      ..add(_caughtUp.listen((_) => _soon()));
  }

  void _soon() {
    _debounce?.cancel();
    _debounce = Timer(
      delay,
      () => unawaited(_check().catchError((Object _) {})),
    );
  }

  Future<void> stop() async {
    _debounce?.cancel();
    _debounce = null;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
  }
}

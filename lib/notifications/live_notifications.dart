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
    this.history,
    this.active = _always,
    this.delay = const Duration(seconds: 2),
  }) : _historyPending = history != null;

  final Stream<ServerEvent> _applied;
  final Stream<void> _caughtUp;

  /// [afterGap]: events may have been missed, so the posts come from the
  /// server instead of the database.
  final Future<void> Function({required bool afterGap}) _check;

  /// Given, the first catch-up after [start] (or [rearm]) is history: it is
  /// called with the server time of the first post that arrived live before
  /// it, or null, and must treat everything older as seen. Only what arrives
  /// from then on gets checked.
  final Future<void> Function(DateTime? liveFrom)? history;

  /// Whether checking makes sense now. While not, events are ignored, and
  /// the app is expected to [rearm] when it goes inactive.
  final bool Function() active;

  static bool _always() => true;

  /// Posts often come in bursts; one check covers them.
  final Duration delay;

  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _debounce;
  var _gap = false;
  bool _historyPending;
  DateTime? _liveFrom;
  var _sawLive = false;

  /// The next catch-up is history again, for when the app was away.
  void rearm() {
    if (history == null) return;
    _historyPending = true;
    _liveFrom = null;
    _sawLive = false;
  }

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(
        _applied.listen((e) {
          if (e is PostedEvent) _posted(e);
        }),
      )
      ..add(_caughtUp.listen((_) => unawaited(_caughtUpNow())));
  }

  void _posted(PostedEvent e) {
    if (!active()) return;
    if (_historyPending) {
      _sawLive = true;
      final at = e.post?.createAt;
      if (at != null && (_liveFrom == null || at.isBefore(_liveFrom!))) {
        _liveFrom = at;
      }
    }
    _soon();
  }

  Future<void> _caughtUpNow() async {
    if (!active()) return;
    if (_historyPending) {
      final live = _sawLive;
      await _settleHistory();
      if (!live) return;
    }
    _gap = true;
    _soon();
  }

  Future<void> _settleHistory() async {
    if (!_historyPending) return;
    _historyPending = history != null;
    final liveFrom = _liveFrom;
    final sawLive = _sawLive;
    _liveFrom = null;
    _sawLive = false;
    if (sawLive && liveFrom == null) return;
    await history!(liveFrom);
  }

  void _soon() {
    _debounce?.cancel();
    _debounce = Timer(delay, () async {
      if (!active()) return;
      await _settleHistory();
      if (_subscriptions.isEmpty) return;
      final afterGap = _gap;
      _gap = false;
      unawaited(_check(afterGap: afterGap).catchError((Object _) {}));
    });
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

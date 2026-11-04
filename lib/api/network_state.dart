import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/log.dart';

/// Pure: whether a connectivity report names any network. An empty report
/// says nothing, so it counts as a network.
bool hasNetwork(List<ConnectivityResult> report) =>
    report.isEmpty || report.any((r) => r != ConnectivityResult.none);

/// Whether the device has a network at all, from the system's connectivity
/// reports. A network doesn't mean the server answers (captive portals,
/// VPNs, dead mobile data), so only "no network" is acted on; being online
/// is never taken as proof of anything.
class NetworkState {
  NetworkState(Stream<List<ConnectivityResult>> reports) {
    _subscription = reports.listen(
      _report,
      // Without the plugin (some background engines) or NetworkManager the
      // app stays online, and what waits for a first report (images) goes
      // ahead as on an unknown network.
      onError: (Object e) {
        Log.warn('network', 'No connectivity reports', e);
        if (_last == null) _report(const []);
      },
    );
  }

  /// The device's own reports, the current state first.
  factory NetworkState.device() {
    final connectivity = Connectivity();
    return NetworkState(
      deviceReports(
        connectivity.checkConnectivity,
        () => connectivity.onConnectivityChanged,
      ),
    );
  }

  /// The current state, then the changes. When the current state can't be
  /// read the changes aren't watched either. The Linux plugin's D-Bus setup
  /// fails in a future nobody awaits, so the read runs in a guarded zone
  /// that turns such an escape into its error.
  static Stream<List<ConnectivityResult>> deviceReports(
    Future<List<ConnectivityResult>> Function() current,
    Stream<List<ConnectivityResult>> Function() changes,
  ) async* {
    final first = Completer<List<ConnectivityResult>>();
    void fail(Object error, StackTrace stack) {
      if (!first.isCompleted) first.completeError(error, stack);
    }

    runZonedGuarded(() {
      unawaited(
        current().then((report) {
          if (!first.isCompleted) first.complete(report);
        }, onError: fail),
      );
    }, fail);
    yield await first.future;
    yield* changes();
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  final _online = ValueNotifier(true);
  final _reports = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult>? _last;

  /// False only while the system reports no network.
  ValueListenable<bool> get online => _online;
  bool get offline => !_online.value;

  /// The latest report, null until the first one.
  List<ConnectivityResult>? get last => _last;
  Stream<List<ConnectivityResult>> get reports => _reports.stream;

  /// A server answered, so there is a network whatever the last report said.
  void reachable() => _online.value = true;

  void _report(List<ConnectivityResult> report) {
    _last = report;
    _reports.add(report);
    _online.value = hasNetwork(report);
  }

  Future<void> close() async {
    await _subscription.cancel();
    await _reports.close();
    _online.dispose();
  }
}

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
    return NetworkState(() async* {
      yield await connectivity.checkConnectivity();
      yield* connectivity.onConnectivityChanged;
    }());
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

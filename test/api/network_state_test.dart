import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/network_state.dart';

void main() {
  test('without connectivity reports the network counts as present and '
      'unknown, so what waits for a first report goes ahead', () async {
    final reports = StreamController<List<ConnectivityResult>>();
    final network = NetworkState(reports.stream);
    final seen = <List<ConnectivityResult>>[];
    final sub = network.reports.listen(seen.add);
    reports.addError(Exception('NetworkManager is not running'));
    await pumpEventQueue();
    expect(network.last, isEmpty);
    expect(network.online.value, isTrue);
    expect(seen, [isEmpty]);
    await sub.cancel();
    await network.close();
    await reports.close();
  });

  test('a later failure keeps the last real report', () async {
    final reports = StreamController<List<ConnectivityResult>>();
    final network = NetworkState(reports.stream);
    reports.add([ConnectivityResult.none]);
    await pumpEventQueue();
    reports.addError(Exception('NetworkManager went away'));
    await pumpEventQueue();
    expect(network.last, [ConnectivityResult.none]);
    expect(network.online.value, isFalse);
    await network.close();
    await reports.close();
  });
}

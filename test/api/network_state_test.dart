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

  test('an unreadable current state counts as unknown and the changes are '
      'never listened to', () async {
    var listened = false;
    final network = NetworkState(
      NetworkState.deviceReports(
        () async => throw Exception('no system bus'),
        () {
          listened = true;
          return const Stream.empty();
        },
      ),
    );
    await pumpEventQueue();
    expect(network.last, isEmpty);
    expect(network.online.value, isTrue);
    expect(listened, isFalse);
    await network.close();
  });

  test('a failure that escapes the read in a future nobody awaits still '
      'counts as unknown', () async {
    final network = NetworkState(
      NetworkState.deviceReports(() {
        Future<void>.delayed(Duration.zero, () => throw Exception('no bus'));
        return Completer<List<ConnectivityResult>>().future;
      }, () => const Stream.empty()),
    );
    await pumpEventQueue();
    expect(network.last, isEmpty);
    expect(network.online.value, isTrue);
    await network.close();
  });

  test('changes that fail on listen count as unknown once', () async {
    final network = NetworkState(
      NetworkState.deviceReports(
        () async => [ConnectivityResult.wifi],
        () => Stream.error(Exception('no system bus')),
      ),
    );
    await pumpEventQueue();
    expect(network.last, [ConnectivityResult.wifi]);
    expect(network.online.value, isTrue);
    await network.close();
  });
}

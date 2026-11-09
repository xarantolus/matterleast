import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/guarded_connectivity.dart';

class _Platform extends ConnectivityPlatform {
  _Platform(this.check);
  final Future<List<ConnectivityResult>> Function() check;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() => check();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

void main() {
  test('a readable network is reported with its changes', () async {
    final guarded = GuardedConnectivity(
      _Platform(() async => [ConnectivityResult.ethernet]),
    );
    expect(await guarded.checkConnectivity(), [ConnectivityResult.ethernet]);
    expect(await guarded.onConnectivityChanged.first, [
      ConnectivityResult.wifi,
    ]);
  });

  test('a read that fails is an unknown network, without changes', () async {
    final guarded = GuardedConnectivity(
      _Platform(() async => throw Exception('no system bus')),
    );
    expect(await guarded.checkConnectivity(), [ConnectivityResult.other]);
    expect(await guarded.onConnectivityChanged.isEmpty, isTrue);
  });

  test('a failure in a future nobody awaits does not hang the read', () async {
    final guarded = GuardedConnectivity(
      _Platform(() {
        Future<void>.delayed(Duration.zero, () => throw Exception('no bus'));
        return Completer<List<ConnectivityResult>>().future;
      }),
    );
    expect(await guarded.checkConnectivity(), [ConnectivityResult.other]);
  });
}

import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

/// The platform's connectivity answers, except that a failure to read them
/// (Linux without a system bus or NetworkManager) is an unknown network
/// instead of an error. The Linux plugin fails in a future nobody awaits,
/// which hangs whoever asked, such as LiveKit before it connects.
class GuardedConnectivity extends ConnectivityPlatform {
  GuardedConnectivity(this._inner);

  final ConnectivityPlatform _inner;
  var _readable = true;

  /// Wraps the current platform implementation, once.
  static void install() {
    if (ConnectivityPlatform.instance is GuardedConnectivity) return;
    ConnectivityPlatform.instance = GuardedConnectivity(
      ConnectivityPlatform.instance,
    );
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    final answer = Completer<List<ConnectivityResult>>();
    void fail(Object error, StackTrace stack) {
      if (!answer.isCompleted) answer.completeError(error, stack);
    }

    runZonedGuarded(() {
      unawaited(
        _inner.checkConnectivity().then((report) {
          if (!answer.isCompleted) answer.complete(report);
        }, onError: fail),
      );
    }, fail);
    try {
      return await answer.future;
    } on Object {
      _readable = false;
      return const [ConnectivityResult.other];
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    if (_readable) yield* _inner.onConnectivityChanged;
  }
}

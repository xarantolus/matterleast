import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/log.dart';

/// Whether one server answers, judged from evidence: the device can have a
/// network that carries nothing (dead mobile data, a captive portal, a VPN
/// without uplink), where every request would wait for its timeout.
///
/// The server counts as unreachable once a request got no answer while
/// its socket wasn't connected either; any answer or a connected socket
/// makes it reachable again. While unreachable, [probe] asks cheaply
/// whether it answers again, so nothing else waits for a long timeout.
class ServerReach {
  ServerReach({
    required this._ping,
    this.probeMemory = defaultProbeMemory,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _reachable.addListener(
      () => Log.info(
        'reach',
        _reachable.value ? 'Server answers again' : 'Server not answering',
      ),
    );
  }

  /// A failed probe stands for this long, so a burst of requests doesn't
  /// send a burst of pings.
  static const defaultProbeMemory = Duration(seconds: 5);
  final Duration probeMemory;

  /// How long a request without an answer counts as evidence when the
  /// socket fails afterwards.
  static const evidenceWindow = Duration(minutes: 1);

  final Future<bool> Function() _ping;
  final DateTime Function() _clock;
  final _reachable = ValueNotifier(true);
  var _socketConnected = false;
  DateTime? _lastNoAnswer;
  DateTime? _lastFailedProbe;
  Future<bool>? _probing;

  /// False while the server is known not to answer.
  ValueListenable<bool> get reachable => _reachable;
  bool get unreachable => !_reachable.value;

  /// The server answered something, even an error.
  void answered() {
    _lastFailedProbe = null;
    _reachable.value = true;
  }

  /// Asked to make sure a socket that counts as connected still is, when
  /// a request got no answer meanwhile.
  void Function()? checkSocket;

  /// A request ended without any answer (connect or receive timeout).
  void noAnswer() {
    _lastNoAnswer = _clock();
    if (_socketConnected) {
      checkSocket?.call();
    } else {
      _reachable.value = false;
    }
  }

  void socketConnected() {
    _socketConnected = true;
    answered();
  }

  /// The socket closed or couldn't connect.
  void socketDown() {
    _socketConnected = false;
    final last = _lastNoAnswer;
    if (last != null && _clock().difference(last) < evidenceWindow) {
      _reachable.value = false;
    }
  }

  /// Whether the server answers now. While it is believed reachable that
  /// is taken as given; otherwise one short ping, shared by everyone who
  /// asks meanwhile.
  Future<bool> probe() {
    if (_reachable.value) return Future.value(true);
    final failed = _lastFailedProbe;
    if (failed != null && _clock().difference(failed) < probeMemory) {
      return Future.value(false);
    }
    return _probing ??= _ping()
        .then((ok) {
          if (ok) {
            answered();
          } else {
            _lastFailedProbe = _clock();
          }
          return ok;
        })
        .whenComplete(() => _probing = null);
  }

  void dispose() => _reachable.dispose();
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/log.dart';

/// Debug builds only: counts requests and WebSocket events per kind (never
/// their content) and logs the totals every few minutes.
abstract final class TrafficLog {
  static final _counts = <String, (int, int)>{};
  static Timer? _timer;

  static final _id = RegExp(r'[a-z0-9]{26}');

  static void request(String method, String path, int bytes) =>
      _add('$method ${path.replaceAll(_id, ':id')}', bytes);

  static void event(String type, int bytes) => _add('ws $type', bytes);

  static void _add(String key, int bytes) {
    if (!kDebugMode) return;
    final (count, total) = _counts[key] ?? (0, 0);
    _counts[key] = (count + 1, total + bytes);
    _timer ??= Timer.periodic(const Duration(minutes: 5), (_) => _dump());
  }

  static void _dump() {
    final rows = _counts.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    for (final MapEntry(key: key, value: (count, bytes)) in rows) {
      Log.info('traffic', '$key x$count $bytes B');
    }
    Log.info('traffic', '--- end of totals');
  }
}

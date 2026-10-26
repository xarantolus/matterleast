import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Waits until [condition] holds, so a test waits on what it needs rather
/// than on a guessed time; fails with [reason] after [timeout].
Future<void> eventually(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail(reason ?? 'the condition did not hold within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:matterleast/domain/today.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_provider.g.dart';

/// The local day, for "Today" and "Yesterday" labels. It changes at local
/// midnight and is checked again when the app comes back, so labels follow
/// the date without rebuilding more than once a day.
@Riverpod(keepAlive: true)
class Today extends _$Today {
  Timer? _timer;

  @override
  DateTime build() {
    final lifecycle = AppLifecycleListener(onResume: _check);
    ref.onDispose(() {
      _timer?.cancel();
      lifecycle.dispose();
    });
    _schedule();
    return localDay(DateTime.now());
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(untilNextDay(DateTime.now()), _check);
  }

  void _check() {
    final day = localDay(DateTime.now());
    if (day != state) state = day;
    _schedule();
  }
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:matterleast/app/platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_saver.g.dart';

const _channel = MethodChannel('matterleast/data_saver');

/// Whether Android's Data Saver or iOS Low Data Mode restricts this app;
/// never on desktop. The phone reports every change.
@Riverpod(keepAlive: true)
Stream<bool> dataSaver(Ref ref) {
  final changes = StreamController<bool>();
  ref.onDispose(() {
    _channel.setMethodCallHandler(null);
    unawaited(changes.close());
  });
  if (isDesktop) {
    changes.add(false);
    return changes.stream;
  }
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'changed') {
      if (call.arguments case final bool restricted) changes.add(restricted);
    }
  });
  unawaited(_read().then(changes.add));
  return changes.stream;
}

Future<bool> _read() async {
  try {
    return await _channel.invokeMethod<bool>('restricted') ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:matterleast/log.dart';

/// The window's taskbar button on Windows (windows/runner/taskbar.cpp);
/// nothing elsewhere.
abstract final class Taskbar {
  static const _channel = MethodChannel('matterleast/taskbar');

  /// 0 removes the overlay, 1–9 show that number and 10 shows "9+".
  static Future<void> setOverlay(int badge) => _call('setOverlay', badge);

  static Future<void> flash() => _call('flash');

  static Future<void> _call(String method, [Object? argument]) async {
    if (!Platform.isWindows) return;
    try {
      await _channel.invokeMethod<void>(method, argument);
    } on Object catch (e) {
      Log.warn('desktop', 'Taskbar $method failed', e);
    }
  }
}

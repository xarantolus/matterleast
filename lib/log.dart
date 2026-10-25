import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// The only logging entry point. Messages name what happened, never message
/// text or tokens; [redact] strips anything that looks like one.
abstract final class Log {
  static final _secret = RegExp(
    r'(Bearer\s+|MMAUTHTOKEN=|token=|Token:\s*)[A-Za-z0-9._\-]+',
    caseSensitive: false,
  );

  static String redact(String text) =>
      text.replaceAllMapped(_secret, (m) => '${m.group(1)}<redacted>');

  static void info(String area, String message) => _emit(area, message, 800);

  static void warn(String area, String message, [Object? error]) =>
      _emit(area, message, 900, error);

  static void error(
    String area,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) => _emit(area, message, 1000, error, stack);

  static void _emit(
    String area,
    String message,
    int level, [
    Object? error,
    StackTrace? stack,
  ]) {
    if (!kDebugMode && level < 900) return;
    developer.log(
      redact(message),
      name: area,
      level: level,
      error: error == null ? null : redact(error.toString()),
      stackTrace: stack,
    );
  }
}

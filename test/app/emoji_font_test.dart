import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/theme.dart';

void main() {
  List<String>? fallbackOn(TargetPlatform platform) {
    debugDefaultTargetPlatformOverride = platform;
    try {
      final theme = themeForPlatform(buildTheme(Brightness.light));
      return theme.textTheme.bodyMedium?.fontFamilyFallback;
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  test('Linux draws emoji with the bundled font', () {
    expect(fallbackOn(TargetPlatform.linux), contains(emojiFont));
  });

  test('other platforms keep their system emoji font', () {
    for (final platform in [TargetPlatform.windows, TargetPlatform.android]) {
      expect(
        fallbackOn(platform) ?? const <String>[],
        isNot(contains(emojiFont)),
      );
    }
  });
}

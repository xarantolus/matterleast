import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/ui/tokens.dart';

void main() {
  final themes = [MatterleastApp.lightTheme, MatterleastApp.darkTheme];

  test('light and dark disagree about brightness', () {
    expect(MatterleastApp.lightTheme.brightness, Brightness.light);
    expect(MatterleastApp.darkTheme.brightness, Brightness.dark);
  });

  test('white app bar text stays readable on the brand colour', () {
    for (final theme in themes) {
      final fill = theme.appBarTheme.backgroundColor!;
      expect(fill, theme.colorScheme.primary);
      expect(
        contrast(Colors.white, fill),
        greaterThanOrEqualTo(4.5),
        reason: 'white on primary in the ${theme.brightness.name} theme',
      );
    }
  });

  test('every small-text pair clears 4.5:1', () {
    for (final theme in themes) {
      final tokens = theme.extension<AppTokens>()!;
      for (final entry in tokens.textPairs.entries) {
        final (fg, bg) = entry.value;
        expect(
          contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key} in the ${theme.brightness.name} theme',
        );
      }
      expect(
        contrast(theme.colorScheme.surfaceAccent, theme.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('pages use the predictive back transition on Android', () {
    for (final theme in themes) {
      expect(
        theme.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<PredictiveBackPageTransitionsBuilder>(),
      );
    }
  });
}

/// WCAG relative contrast between two opaque colours.
double contrast(Color a, Color b) {
  final high = max(a.computeLuminance(), b.computeLuminance());
  final low = min(a.computeLuminance(), b.computeLuminance());
  return (high + 0.05) / (low + 0.05);
}

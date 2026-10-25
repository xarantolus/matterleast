import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/domain/server_theme.dart';
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

  testWidgets('app bar icons, search included, clear 4.5:1 on the brand', (
    tester,
  ) async {
    for (final theme in themes) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              actions: [
                SearchAnchor(
                  builder: (_, _) => IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                  suggestionsBuilder: (_, _) => const [],
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ),
      );
      for (final icon in [Icons.search, Icons.add, Icons.arrow_back]) {
        final glyph = tester.widget<RichText>(
          find.descendant(
            of: find.byIcon(icon),
            matching: find.byType(RichText),
          ),
        );
        expect(
          contrast(
            glyph.text.style!.color!,
            theme.appBarTheme.backgroundColor!,
          ),
          greaterThanOrEqualTo(4.5),
          reason: '$icon in the ${theme.brightness.name} theme',
        );
      }
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
    }
  });

  group('server theme', () {
    final recorded = jsonDecode(
      File('test/fixtures/api/theme_preferences.json').readAsStringSync(),
    ) as List<Object?>;
    final stored = {
      for (final p in recorded)
        if (p case {'name': final String name, 'value': final String value})
          name: value,
    };
    final palettes = {
      'the recorded theme': ServerPalette.of(
        themeForTeam(stored, 'tm000000000000000000000t01', dark: false),
      ),
      'Denim': ServerPalette.of(themeForTeam(const {}, null, dark: false)),
      'Onyx': ServerPalette.of(themeForTeam(const {}, null, dark: true)),
    };

    test('the recorded theme seeds the colours that read', () {
      final palette = palettes['the recorded theme']!;
      expect(palette.dark, isFalse);
      expect(palette.bar, const Color(0xFFF2C94C));
      expect(palette.primary, const Color(0xFF7FB3FF));
      expect(palette.page, const Color(0xFFFFFDF7));
      // White fails 4.5:1 on the pale yellow header and the pale button.
      expect(palette.onBar, isNot(const Color(0xFFFFFFFF)));
      expect(palette.onPrimary, isNot(const Color(0xFFFFFFFF)));
    });

    test('Onyx is dark and Denim light', () {
      expect(buildServerTheme(palettes['Onyx']!).brightness, Brightness.dark);
      expect(buildServerTheme(palettes['Denim']!).brightness, Brightness.light);
    });

    for (final MapEntry(key: name, value: palette) in palettes.entries) {
      test('every pair clears 4.5:1 in $name', () {
        final theme = buildServerTheme(palette);
        final bar = theme.appBarTheme;
        expect(
          contrast(bar.foregroundColor!, bar.backgroundColor!),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        final tokens = theme.extension<AppTokens>()!;
        for (final entry in tokens.textPairs.entries) {
          final (fg, bg) = entry.value;
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: entry.key,
          );
        }
      });
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

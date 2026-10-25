import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// Brand fill for the light theme: white text reads on it at 6.4:1.
const _brandLight = Color(0xFF00695C);

/// Brand fill for the dark theme, a step lighter so it is still visibly the
/// brand against a dark page while white stays at 5.2:1.
const _brandDark = Color(0xFF00796B);

extension SurfaceAccent on ColorScheme {
  /// The brand colour for text and icons drawn *on* a surface. [primary] is a
  /// fill behind white and is too close to a surface to be read as text.
  Color get surfaceAccent => brightness == Brightness.dark
      ? AppTokens.dark.accent
      : AppTokens.light.accent;
}

ThemeData buildTheme(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;
  final brand = brightness == Brightness.dark ? _brandDark : _brandLight;
  final scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness)
      .copyWith(
        primary: brand,
        onPrimary: Colors.white,
        surface: tokens.page,
        onSurface: tokens.text,
        onSurfaceVariant: tokens.muted,
        outline: tokens.divider,
        outlineVariant: tokens.hairline,
      );
  final base = ThemeData(colorScheme: scheme, brightness: brightness);
  return base.copyWith(
    extensions: [tokens],
    scaffoldBackgroundColor: tokens.page,
    appBarTheme: AppBarTheme(
      backgroundColor: brand,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.surfaceAccent,
      linearTrackColor: tokens.hairline,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.surfaceAccent),
    ),
    dividerTheme: DividerThemeData(color: tokens.hairline, space: 1),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg),
    ),
  );
}

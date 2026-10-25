import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/ui/tokens.dart';

/// Brand fill for the light theme: white text reads on it at 6.4:1.
const _brandLight = Color(0xFF00695C);

/// Brand fill for the dark theme, a step lighter so it is still visibly the
/// brand against a dark page while white stays at 5.2:1.
const _brandDark = Color(0xFF00796B);

ThemeData buildTheme(Brightness brightness) {
  final brand = brightness == Brightness.dark ? _brandDark : _brandLight;
  return _build(
    brightness: brightness,
    tokens: brightness == Brightness.dark ? AppTokens.dark : AppTokens.light,
    primary: brand,
    onPrimary: Colors.white,
    bar: brand,
    onBar: Colors.white,
  );
}

/// The theme seeded from the user's Mattermost theme on a server.
ThemeData buildServerTheme(ServerPalette palette) => _build(
  brightness: palette.dark ? Brightness.dark : Brightness.light,
  tokens: serverTokens(palette),
  primary: palette.primary,
  onPrimary: palette.onPrimary,
  bar: palette.bar,
  onBar: palette.onBar,
);

/// Surface tokens for a server theme, each text pair kept readable.
AppTokens serverTokens(ServerPalette palette) {
  final base = palette.dark ? AppTokens.dark : AppTokens.light;
  final page = palette.page;
  final text = palette.text;
  Color mix(double t) => Color.lerp(page, text, t)!;
  final panel = mix(0.08);
  final wash = Color.lerp(page, palette.accent, 0.14)!;
  return base.copyWith(
    page: page,
    text: text,
    muted: adjustToRead(adjustToRead(mix(0.62), panel), page),
    hairline: mix(0.14),
    divider: mix(0.32),
    accent: adjustToRead(adjustToRead(palette.accent, panel), wash),
    accentWash: wash,
    codeBackground: mix(0.05),
    panel: panel,
    unread: text,
  );
}

ThemeData _build({
  required Brightness brightness,
  required AppTokens tokens,
  required Color primary,
  required Color onPrimary,
  required Color bar,
  required Color onBar,
}) {
  final scheme =
      ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
        primary: primary,
        onPrimary: onPrimary,
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
      backgroundColor: bar,
      foregroundColor: onBar,
      scrolledUnderElevation: 0,
      systemOverlayStyle: bar.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tokens.accent,
      linearTrackColor: tokens.hairline,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: tokens.accent),
    ),
    dividerTheme: DividerThemeData(color: tokens.hairline, space: 1),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg),
    ),
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/wallpaper_colours.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/ui/tokens.dart';

/// Brand fill for the light theme: white text reads on it at 6.4:1.
const _brandLight = Color(0xFF00695C);

/// Brand fill for the dark theme, a step lighter so it is still visibly the
/// brand against a dark page while white stays at 5.2:1.
const _brandDark = Color(0xFF00796B);

/// The bundled typeface; emoji fall back to the system's emoji font.
const appFont = 'Rubik';

/// Rubik's licence on the app's licence page.
void registerFontLicence() => LicenseRegistry.addLicense(() async* {
  yield LicenseEntryWithLineBreaks(const [
    appFont,
  ], await rootBundle.loadString('assets/fonts/Rubik-OFL.txt'));
});

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
ThemeData buildServerTheme(ServerPalette palette) {
  final brightness = palette.dark ? Brightness.dark : Brightness.light;
  final tokens = serverTokens(palette);
  Color mix(double t) => Color.lerp(palette.page, palette.text, t)!;
  // Sheets, menus and dialogs sit on the server's page colour, not on
  // neutrals tinted by the button colour.
  final scheme =
      ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
      ).copyWith(
        surfaceContainerLowest: palette.page,
        surfaceContainerLow: mix(0.03),
        surfaceContainer: mix(0.05),
        surfaceContainerHigh: mix(0.08),
        surfaceContainerHighest: tokens.panel,
      );
  return _build(
    brightness: brightness,
    tokens: tokens,
    primary: palette.primary,
    onPrimary: palette.onPrimary,
    bar: palette.bar,
    onBar: palette.onBar,
    scheme: scheme,
  );
}

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
    muted: _readOnAll(mix(0.62), [panel, wash, page]),
    hairline: mix(0.14),
    divider: mix(0.32),
    accent: _readOnAll(palette.accent, [panel, wash, page]),
    accentWash: wash,
    codeBackground: mix(0.05),
    panel: panel,
    unread: text,
    online: _visibleOn(base.online, page),
    away: _visibleOn(base.away, page),
    busy: _visibleOn(base.busy, page),
  );
}

Color _readOnAll(Color colour, List<Color> backgrounds) =>
    backgrounds.fold(colour, adjustToRead);

Color _visibleOn(Color colour, Color background) =>
    adjustToRead(colour, background, minimum: minShapeContrast);

/// The theme from the phone's wallpaper colours (Material You).
ThemeData buildWallpaperTheme(WallpaperColours colours, Brightness brightness) {
  final scheme = colours.scheme(brightness);
  final onPrimary = readableOn(scheme.primary, scheme.onPrimary);
  return _build(
    brightness: brightness,
    tokens: wallpaperTokens(scheme),
    primary: scheme.primary,
    onPrimary: onPrimary,
    bar: scheme.primary,
    onBar: onPrimary,
    scheme: scheme,
  );
}

/// Surface tokens from a wallpaper scheme, each text pair kept readable.
AppTokens wallpaperTokens(ColorScheme scheme) {
  final base = scheme.brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;
  final page = scheme.surface;
  final panel = scheme.surfaceContainerHighest;
  final code = scheme.surfaceContainer;
  final wash = scheme.primaryContainer;
  return base.copyWith(
    page: page,
    text: _readOnAll(scheme.onSurface, [code, page]),
    muted: _readOnAll(scheme.onSurfaceVariant, [panel, code, page]),
    hairline: scheme.outlineVariant,
    divider: scheme.outline,
    accent: _readOnAll(scheme.primary, [panel, wash, page]),
    accentWash: wash,
    codeBackground: code,
    panel: panel,
    unread: _readOnAll(scheme.onSurface, [page]),
    online: _visibleOn(base.online, page),
    away: _visibleOn(base.away, page),
    busy: _visibleOn(base.busy, page),
  );
}

/// [primary] seeds the scheme, but Material also draws `colorScheme.primary`
/// as text and outlines on the page (focused fields, switches, tabs), so
/// the scheme takes the accent, which reads there, with the colour on it
/// computed. The same goes for `error`.
ThemeData _build({
  required Brightness brightness,
  required AppTokens tokens,
  required Color primary,
  required Color onPrimary,
  required Color bar,
  required Color onBar,
  ColorScheme? scheme,
}) {
  final seeded =
      scheme ??
      ColorScheme.fromSeed(seedColor: primary, brightness: brightness);
  final error = [tokens.page, tokens.panel].fold(seeded.error, adjustToRead);
  final colours = seeded.copyWith(
    primary: tokens.accent,
    onPrimary: readableOn(tokens.accent, onPrimary),
    error: error,
    onError: readableOn(error, seeded.onError),
    surface: tokens.page,
    onSurface: tokens.text,
    onSurfaceVariant: tokens.muted,
    outline: tokens.divider,
    outlineVariant: tokens.hairline,
  );
  final base = ThemeData(
    colorScheme: colours,
    brightness: brightness,
    fontFamily: appFont,
  );
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
    // Material's widest dialog; a desktop window would stretch it further.
    dialogTheme: const DialogThemeData(
      constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
    ),
  );
}

/// [theme] as it is on a phone, at desktop sizes on desktop.
ThemeData themeForPlatform(ThemeData theme) =>
    isDesktop ? desktopTheme(theme) : theme;

/// [theme] at mouse and keyboard sizes for a desktop window, near Discord's
/// and the Mattermost desktop app's at 100 %: 14 px text, 36 to 44 px list rows,
/// 48 px app bars and 32 px icon buttons, and no ripples. Phones keep
/// [theme] as it is.
ThemeData desktopTheme(ThemeData theme) {
  final text = theme.textTheme;
  final colours = theme.colorScheme;
  TextStyle? sized(TextStyle? style, double size) =>
      style?.copyWith(fontSize: size);
  final textTheme = text.copyWith(
    headlineSmall: sized(text.headlineSmall, 20),
    titleLarge: sized(text.titleLarge, 18),
    titleMedium: sized(text.titleMedium, 15),
    bodyLarge: sized(text.bodyLarge, 14),
  );
  // Flutter's desktop default over buttons is the arrow.
  const click = WidgetStateMouseCursor.clickable;
  ButtonStyle clickable(ButtonStyle? style) =>
      (style ?? const ButtonStyle()).copyWith(mouseCursor: click);
  return theme.copyWith(
    // Ripples are for fingers.
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: textTheme,
    appBarTheme: theme.appBarTheme.copyWith(toolbarHeight: 48),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: 20,
        minimumSize: const Size.square(32),
        padding: const EdgeInsets.all(6),
      ).copyWith(mouseCursor: click),
    ),
    textButtonTheme: TextButtonThemeData(
      style: clickable(theme.textButtonTheme.style),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: clickable(theme.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: clickable(theme.outlinedButtonTheme.style),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: clickable(theme.elevatedButtonTheme.style),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: clickable(theme.segmentedButtonTheme.style),
    ),
    menuButtonTheme: MenuButtonThemeData(
      style: clickable(theme.menuButtonTheme.style),
    ),
    popupMenuTheme: theme.popupMenuTheme.copyWith(mouseCursor: click),
    floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
      mouseCursor: click,
    ),
    tabBarTheme: theme.tabBarTheme.copyWith(mouseCursor: click),
    switchTheme: theme.switchTheme.copyWith(mouseCursor: click),
    checkboxTheme: theme.checkboxTheme.copyWith(mouseCursor: click),
    radioTheme: theme.radioTheme.copyWith(mouseCursor: click),
    listTileTheme: theme.listTileTheme.copyWith(
      // One line 36 px dense and 44 px otherwise, two lines 60 px.
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      titleTextStyle: textTheme.bodyLarge?.copyWith(color: colours.onSurface),
      subtitleTextStyle: sized(
        textTheme.bodyMedium,
        13,
      )?.copyWith(color: colours.onSurfaceVariant),
    ),
    searchBarTheme: theme.searchBarTheme.copyWith(
      constraints: const BoxConstraints(
        minWidth: 360,
        maxWidth: 800,
        minHeight: 40,
      ),
    ),
  );
}

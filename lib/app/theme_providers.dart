import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/wallpaper_colours.dart';
import 'package:matterleast/data/views/settings_views.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// Null themes keep the brand; [mode] picks light, dark or the system's.
typedef AppThemes = ({ThemeData? light, ThemeData? dark, ThemeMode mode});

const AppThemes brandSystem = (light: null, dark: null, mode: ThemeMode.system);

ThemeMode themeModeFor(ThemeBrightness brightness) => switch (brightness) {
  ThemeBrightness.system => ThemeMode.system,
  ThemeBrightness.light => ThemeMode.light,
  ThemeBrightness.dark => ThemeMode.dark,
};

/// The themes and mode for the colours the server in use is set to.
@riverpod
Future<AppThemes> appThemes(Ref ref) async {
  final server = ref.watch(settingsServerProvider);
  if (server == null) return brandSystem;
  final source = await ref.watch(themeModeProvider(server.url).future);
  final mode = themeModeFor(source.brightness);
  switch (source.family) {
    case ThemeFamily.brand:
      return (light: null, dark: null, mode: mode);
    case ThemeFamily.server:
      final palettes = await ref.watch(
        serverPalettesProvider(server.url).future,
      );
      return (
        light: buildServerTheme(palettes.light),
        dark: buildServerTheme(palettes.dark),
        mode: mode,
      );
    case ThemeFamily.wallpaper:
      final palette = await ref.watch(wallpaperPaletteProvider.future);
      if (palette == null) return (light: null, dark: null, mode: mode);
      return (
        light: buildWallpaperTheme(palette, Brightness.light),
        dark: buildWallpaperTheme(palette, Brightness.dark),
        mode: mode,
      );
  }
}

/// The user's Mattermost theme on the server at [url].
@riverpod
Stream<ServerPalettes> serverPalettes(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* SettingsViews(db).palettes();
}

/// The phone's wallpaper colours, read again when the app comes back, since
/// the wallpaper may have changed meanwhile. Null where the phone has none
/// (before Android 12).
@Riverpod(keepAlive: true)
class WallpaperPalette extends _$WallpaperPalette {
  @override
  Future<WallpaperColours?> build() async {
    final listener = AppLifecycleListener(onResume: _reload);
    ref.onDispose(listener.dispose);
    return _read();
  }

  Future<void> _reload() async {
    final palette = await _read();
    if (ref.mounted && palette != state.value) state = AsyncData(palette);
  }

  static Future<WallpaperColours?> _read() async {
    try {
      final tones = await DynamicColorPlugin.channel.invokeListMethod<int>(
        DynamicColorPlugin.methodName,
      );
      return tones == null ? null : WallpaperColours(tones);
    } on Exception catch (e) {
      Log.warn('theme', 'Reading the wallpaper colours failed', e);
      return null;
    }
  }
}

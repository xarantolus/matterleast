import 'package:drift/drift.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/wallpaper_colours.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

typedef AppThemes = ({ThemeData light, ThemeData dark});

/// The themes for the light and dark system setting from the colours the
/// server in use is set to; null keeps the brand.
@riverpod
Future<AppThemes?> appThemes(Ref ref) async {
  final server = ref.watch(settingsServerProvider);
  if (server == null) return null;
  switch (await ref.watch(themeModeProvider(server.url).future)) {
    case ThemeSource.brand:
      return null;
    case ThemeSource.server:
      final palettes = await ref.watch(
        serverPalettesProvider(server.url).future,
      );
      return (
        light: buildServerTheme(palettes.light),
        dark: buildServerTheme(palettes.dark),
      );
    case ThemeSource.wallpaper:
      final palette = await ref.watch(wallpaperPaletteProvider.future);
      if (palette == null) return null;
      return (
        light: buildWallpaperTheme(palette, Brightness.light),
        dark: buildWallpaperTheme(palette, Brightness.dark),
      );
  }
}

typedef ServerPalettes = ({ServerPalette light, ServerPalette dark});

/// The user's Mattermost theme on the server at [url].
@riverpod
Stream<ServerPalettes> serverPalettes(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([db.preferences, db.syncState]),
    ),
    () => _palettes(db),
    interval: const Duration(milliseconds: 300),
  ).distinct();
}

Future<ServerPalettes> _palettes(ServerDatabase db) async {
  final rows = await (db.select(
    db.preferences,
  )..where((p) => p.category.equals('theme'))).get();
  final themes = {for (final row in rows) row.name: row.value};
  final team = await db.syncText(SyncKeys.currentTeamId);
  return (
    light: ServerPalette.of(themeForTeam(themes, team, dark: false)),
    dark: ServerPalette.of(themeForTeam(themes, team, dark: true)),
  );
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

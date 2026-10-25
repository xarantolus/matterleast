import 'package:drift/drift.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// The colours for the light and dark system setting, when the server in
/// use is set to its own theme; null keeps the brand.
typedef ServerPalettes = ({ServerPalette light, ServerPalette dark});

@riverpod
Stream<ServerPalettes?> serverPalettes(Ref ref) async* {
  final server = ref.watch(settingsServerProvider);
  if (server == null) {
    yield null;
    return;
  }
  final mode = await ref.watch(themeModeProvider(server.url).future);
  if (mode != 'server') {
    yield null;
    return;
  }
  final db = (await ref.watch(serverSessionProvider(server.url).future)).db;
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

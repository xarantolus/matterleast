import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:matterleast/data/app_db/tables.dart';
import 'package:matterleast/data/db/millis.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

const appDatabaseFileName = 'app.sqlite';

/// The server list and the settings; everything else lives in one database
/// per server.
@DriftDatabase(tables: [Servers, SettingEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.connection);

  /// One database isolate per process, shared by the UI and background
  /// isolates, so watchers see every write.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'matterleast_app',
      native: DriftNativeOptions(
        databasePath: () async => p.join(
          (await getApplicationSupportDirectory()).path,
          appDatabaseFileName,
        ),
        shareAcrossIsolates: true,
        setup: configureConnection,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  Stream<List<ServerRow>> watchServers() => (select(
    servers,
  )..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).watch();

  Future<List<ServerRow>> allServers() =>
      (select(servers)..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get();

  Future<ServerRow?> serverByUrl(String url) =>
      (select(servers)..where((s) => s.url.equals(url))).getSingleOrNull();

  Future<ServerRow?> serverByDiagnosticId(String id) => (select(
    servers,
  )..where((s) => s.diagnosticId.equals(id))).getSingleOrNull();

  Future<void> upsertServer(ServersCompanion server) =>
      into(servers).insertOnConflictUpdate(server);

  Future<void> deleteServer(String url) =>
      (delete(servers)..where((s) => s.url.equals(url))).go();

  Future<Map<String, String>> allSettings() async => {
    for (final row in await select(settingEntries).get()) row.key: row.value,
  };

  Stream<Map<String, String>> watchSettings() =>
      select(settingEntries)
          .watch()
          .map((rows) => {for (final row in rows) row.key: row.value});

  Future<void> writeSetting(String key, String value) =>
      into(settingEntries)
          .insertOnConflictUpdate(SettingEntry(key: key, value: value));
}

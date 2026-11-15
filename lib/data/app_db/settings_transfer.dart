import 'package:drift/drift.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/domain/server_url.dart';
import 'package:matterleast/domain/settings_file.dart';

/// Moves the exported settings and the server list between the app database
/// and a [SettingsFile].
class SettingsTransfer {
  SettingsTransfer(this._db);

  final AppDatabase _db;

  Future<List<FileServer>> _servers() async => [
    for (final s in await _db.allServers())
      FileServer(
        url: s.url,
        displayName: s.displayName,
        sortOrder: s.sortOrder,
        themeMode: s.themeMode,
        ssoScheme: s.ssoScheme,
      ),
  ];

  Future<SettingsFile> export({required bool? stayConnected}) async =>
      buildSettingsFile(
        servers: await _servers(),
        stored: await _db.allSettings(),
        stayConnected: stayConnected,
      );

  Future<ImportPlan> plan(
    SettingsFile file, {
    required bool? stayConnected,
  }) async => planImport(
    file,
    servers: await _servers(),
    stored: await _db.allSettings(),
    stayConnected: stayConnected,
  );

  /// Adds the servers (signed out), updates the look of known ones and
  /// writes the settings. Stay connected is the caller's.
  Future<void> apply(ImportPlan plan) => _db.transaction(() async {
    final all = await _db.allServers();
    var next = all.isEmpty
        ? 0
        : all.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    for (final s in [...plan.add]..sort((a, b) => a.sortOrder - b.sortOrder)) {
      await _db.upsertServer(
        ServersCompanion.insert(
          url: s.url,
          displayName: s.displayName,
          dbFile: serverDbFileName(Uri.parse(s.url)),
          sortOrder: Value(next++),
          addedAt: DateTime.now(),
          themeMode: Value(s.themeMode),
          ssoScheme: Value(s.ssoScheme),
        ),
      );
    }
    for (final s in plan.update) {
      await (_db.update(_db.servers)..where((r) => r.url.equals(s.url))).write(
        ServersCompanion(
          themeMode: Value(s.themeMode),
          ssoScheme: Value(s.ssoScheme),
        ),
      );
    }
    for (final MapEntry(:key, :value) in plan.settings.entries) {
      await _db.writeSetting(key, value);
    }
  });
}

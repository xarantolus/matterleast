import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:matterleast/data/db/millis.dart';
import 'package:matterleast/data/server_db/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'server_database.g.dart';

/// Everything cached for one server. One file per server, so logging out is
/// a file delete and one server's writes never wake another's watchers.
@DriftDatabase(
  tables: [
    Users,
    Teams,
    MyTeams,
    Channels,
    MyChannels,
    Categories,
    CategoryChannels,
    Posts,
    PostRanges,
    Reactions,
    Files,
    Threads,
    ThreadTeams,
    ThreadSync,
    CustomEmoji,
    Preferences,
    Roles,
    Drafts,
    Outbox,
    PostLists,
    SearchHistory,
    ViewStates,
    SyncState,
    Config,
  ],
)
class ServerDatabase extends _$ServerDatabase {
  ServerDatabase(super.connection);

  /// Opens (or connects to) the shared isolate for [fileName], e.g.
  /// `server-1a2b3c4d5e6f.sqlite`.
  factory ServerDatabase.open(String fileName) => ServerDatabase(
    driftDatabase(
      name: fileName,
      native: DriftNativeOptions(
        databasePath: () async =>
            p.join((await getApplicationSupportDirectory()).path, fileName),
        shareAcrossIsolates: true,
        setup: configureConnection,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  Future<String?> syncText(String key) async => (await (select(
    syncState,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.valueText;

  Future<int?> syncInt(String key) async => (await (select(
    syncState,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.valueInt;

  Future<void> setSyncText(String key, String? value) => into(syncState)
      .insertOnConflictUpdate(
        SyncStateCompanion.insert(key: key, valueText: Value(value)),
      );

  Future<void> setSyncInt(String key, int? value) => into(syncState)
      .insertOnConflictUpdate(
        SyncStateCompanion.insert(key: key, valueInt: Value(value)),
      );
}

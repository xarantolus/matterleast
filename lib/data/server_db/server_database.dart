import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:matterleast/data/db/millis.dart';
import 'package:matterleast/data/server_db/tables.dart';
import 'package:path/path.dart' as p;

part 'server_database.g.dart';

/// Keys of the `sync_state` table.
abstract final class SyncKeys {
  static const currentUserId = 'current_user_id';
  static const currentTeamId = 'current_team_id';
  static const lastFullSync = 'last_full_sync';
  static String channelsSince(String teamId) => 'channels_since:$teamId';
}

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

  /// Opens (or connects to) the shared isolate for the file at [path], named
  /// like `server-1a2b3c4d-chat_example_com.sqlite`.
  factory ServerDatabase.open(String path) => ServerDatabase(
    driftDatabase(
      name: p.basename(path),
      native: DriftNativeOptions(
        databasePath: () async => path,
        shareAcrossIsolates: true,
        setup: configureConnection,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  /// The signed-in user, once [ServerStore.applyMe] has run.
  Stream<UserRow?> watchMe() {
    final query = select(users).join([
      innerJoin(
        syncState,
        syncState.valueText.equalsExp(users.id) &
            syncState.key.equals(SyncKeys.currentUserId),
      ),
    ]);
    return query.watchSingleOrNull().map((row) => row?.readTable(users));
  }

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

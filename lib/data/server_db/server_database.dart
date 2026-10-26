import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:matterleast/data/db/millis.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/server_db/server_database.steps.dart';
import 'package:matterleast/data/server_db/tables.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:path/path.dart' as p;

part 'server_database.g.dart';

/// Keys of the `sync_state` table.
abstract final class SyncKeys {
  static const currentUserId = 'current_user_id';
  static const currentTeamId = 'current_team_id';
  static const lastFullSync = 'last_full_sync';
  static String channelsSince(String teamId) => 'channels_since:$teamId';

  /// The search terms that find the user's mentions, kept with the user.
  static const mentionTerms = 'mention_terms';

  /// When a post list (`mentions`, `saved`, `threads`) was last fetched.
  static String listFetchedAt(String list) => 'list_fetched_at:$list';

  /// The signed-in user's system roles, space-separated as the server sends
  /// them.
  static const currentUserRoles = 'current_user_roles';

  /// The signed-in user's account notification settings, as JSON.
  static const accountNotifyProps = 'account_notify_props';

  /// The channel the user last opened in a team.
  static String lastChannel(String teamId) => 'last_channel:$teamId';
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.channels, schema.channels.memberCount);
        await m.addColumn(schema.posts, schema.posts.participantIdsJson);
      },
      from2To3: (m, schema) async {
        await m.addColumn(schema.posts, schema.posts.decodeProblem);
      },
    ),
  );

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

  Future<String?> preference(String category, String name) async =>
      (await (select(preferences)..where(
                (p) => p.category.equals(category) & p.name.equals(name),
              ))
              .getSingleOrNull())
          ?.value;

  /// What the server offers, from the stored config, licence and plugins.
  Future<ServerFeatures> features() async =>
      _features(await select(config).get());

  Stream<ServerFeatures> watchFeatures() =>
      select(config).watch().map(_features.call).distinct();

  final _features = _Features();

  /// Whether replies are counted per thread for this user on this server.
  Future<bool> collapsedThreads() async => collapsedThreadsOn(
    (await features()).collapsedThreads,
    await preference(Prefs.collapsedThreads.$1, Prefs.collapsedThreads.$2),
  );

  /// How people are named: the server's setting when locked, else the
  /// user's preference.
  Future<String?> nameFormat() async {
    final features = await this.features();
    if (features.nameDisplayLocked) return features.nameDisplay;
    return await preference(Prefs.nameFormat.$1, Prefs.nameFormat.$2) ??
        features.nameDisplay;
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

class _Features {
  final _decode = FeaturesDecoder();
  ServerFeatures call(List<ConfigRow> rows) =>
      _decode([for (final r in rows) (key: r.key, json: r.json)]);
}

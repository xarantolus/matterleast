import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/servers/entries.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
SettingsStore settingsStore(Ref ref) =>
    SettingsStore(ref.watch(appDatabaseProvider));

/// The rail item shown when the app was last used, read once at launch.
@Riverpod(keepAlive: true)
Future<RailTarget?> savedRailTarget(Ref ref) =>
    ref.watch(settingsStoreProvider).read(Settings.lastRailTarget);

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore();

@Riverpod(keepAlive: true)
ServerManager serverManager(Ref ref) {
  final manager = ServerManager(
    db: ref.watch(appDatabaseProvider),
    tokens: ref.watch(tokenStoreProvider),
    dataDirectory: () async => (await getApplicationSupportDirectory()).path,
    cacheDirectory: () async => p.join(
      await LocalCopies.cacheDirectory(),
      LocalCopies.serverCachesFolder,
    ),
    mediaBudget: () =>
        ref.read(settingsStoreProvider).read(Settings.mediaCacheBytes),
    filesBudget: () =>
        ref.read(settingsStoreProvider).read(Settings.filesCacheBytes),
    clearShared: () async =>
        LocalCopies.clearLooseFiles(await LocalCopies.cacheDirectory()),
  );
  ref.onDispose(manager.dispose);
  return manager;
}

@riverpod
ServerProbe serverProbe(Ref ref) => ServerProbe();

@riverpod
SignIn signIn(Ref ref) => SignIn();

/// Every added server, signed in or not, in rail order.
@riverpod
Stream<List<ServerEntry>> servers(Ref ref) => ref
    .watch(appDatabaseProvider)
    .watchServers()
    .map((rows) => [for (final row in rows) serverEntryOf(row)]);

@Riverpod(keepAlive: true)
Future<ServerSession> serverSession(Ref ref, String url) {
  final manager = ref.watch(serverManagerProvider);
  final changes = manager.changed
      .where((changedUrl) => changedUrl == url)
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);
  return manager.session(url);
}

/// The signed-in user of one server, from its database.
@riverpod
Stream<Me?> currentUser(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.db.watchMe().map((row) => row == null ? null : meOf(row));
}

/// What one server offers, as it changes.
@riverpod
Stream<ServerFeatures> features(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.db.watchFeatures();
}

/// Servers that ended their session, as they happen.
@riverpod
Stream<ServerEntry> sessionEnded(Ref ref) =>
    ref.watch(serverManagerProvider).sessionEnded.map(serverEntryOf);

/// The app's version as people read it, such as `0.1.0 (1)`.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// The clock the user picked; null follows the phone.
@Riverpod(keepAlive: true)
Stream<bool?> use24HourClock(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.use24HourClock);

@Riverpod(keepAlive: true)
Stream<MessageTextSize> messageTextSize(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.messageTextSize);

@Riverpod(keepAlive: true)
Stream<bool> wrapCode(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.wrapCode);

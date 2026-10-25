import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/servers/entries.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/server_entry.dart';
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
TokenStore tokenStore(Ref ref) => TokenStore();

@Riverpod(keepAlive: true)
ServerManager serverManager(Ref ref) {
  final manager = ServerManager(
    db: ref.watch(appDatabaseProvider),
    tokens: ref.watch(tokenStoreProvider),
    dataDirectory: () async => (await getApplicationSupportDirectory()).path,
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

/// Servers that ended their session, as they happen.
@riverpod
Stream<ServerEntry> sessionEnded(Ref ref) =>
    ref.watch(serverManagerProvider).sessionEnded.map(serverEntryOf);

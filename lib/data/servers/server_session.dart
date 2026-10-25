import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

/// Everything that lives per connected server: its HTTP client, database,
/// store and sync runner. Created once per server URL and kept while the app
/// runs; [close] on logout or removal.
class ServerSession {
  ServerSession({
    required this.url,
    required this.api,
    required this.db,
    required this.runner,
  }) : store = ServerStore(db);

  final Uri url;
  final ServerApi api;
  final ServerDatabase db;
  final ServerStore store;
  final SyncRunner runner;

  static Future<ServerSession> open({
    required Uri url,
    required String dbFile,
    required TokenStore tokens,
  }) async {
    await tokens.read(url.toString());
    return ServerSession(
      url: url,
      api: ServerApi(baseUrl: url, token: () => tokens.cached(url.toString())),
      db: ServerDatabase.open(dbFile),
      runner: SyncRunner(),
    );
  }

  Future<void> close() async {
    runner.close();
    api.close();
    await db.close();
  }
}

import 'dart:async';

import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/server_connection.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

/// Everything that lives per connected server: its HTTP client, database,
/// store, sync runner and live connection. Created once per server URL and
/// kept while the app runs; [close] on logout or removal.
class ServerSession {
  ServerSession({
    required this.url,
    required this.api,
    required this.db,
    required this.runner,
    required this.dbPath,
    required String? Function() token,
  }) : store = ServerStore(db) {
    connection = ServerConnection(
      url: url,
      server: api,
      store: store,
      runner: runner,
      token: token,
    );
  }

  final Uri url;
  final ServerApi api;
  final ServerDatabase db;
  final ServerStore store;
  final SyncRunner runner;

  /// The database file, for its size on the status page.
  final String dbPath;
  late final ServerConnection connection;

  /// Opens the session without waiting for the Keystore, so stored data
  /// paints first; requests wait for the token instead.
  static ServerSession open({
    required Uri url,
    required ServerDatabase db,
    required String dbPath,
    required TokenStore tokens,
  }) {
    final key = url.toString();
    unawaited(tokens.read(key));
    return ServerSession(
      url: url,
      api: ServerApi(baseUrl: url, token: () => tokens.read(key)),
      db: db,
      runner: SyncRunner(),
      dbPath: dbPath,
      token: () => tokens.cached(key),
    );
  }

  Future<void> close() async {
    await connection.close();
    runner.close();
    api.close();
    await db.close();
  }
}

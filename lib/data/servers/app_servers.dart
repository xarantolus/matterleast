import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The app's [ServerManager] with its directories and budgets, the same in
/// the UI and in background engines. Background engines pass [shared]
/// false so their databases are their own connections.
ServerManager appServerManager({
  required AppDatabase db,
  required TokenStore tokens,
  bool shared = true,
  void Function(String url, ReadMark mark)? onRead,
  Future<void> Function(String url)? onWiped,
  Future<void> Function(ServerSession session)? onHidden,
  NetworkState? network,
}) {
  final settings = SettingsStore(db);
  return ServerManager(
    db: db,
    tokens: tokens,
    dataDirectory: () async => (await getApplicationSupportDirectory()).path,
    cacheDirectory: () async => p.join(
      await LocalCopies.cacheDirectory(),
      LocalCopies.serverCachesFolder,
    ),
    mediaBudget: () => settings.read(Settings.mediaCacheBytes),
    filesBudget: () => settings.read(Settings.filesCacheBytes),
    clearShared: () async =>
        LocalCopies.clearLooseFiles(await LocalCopies.cacheDirectory()),
    openDatabase: (path) => ServerDatabase.open(path, shared: shared),
    onRead: onRead ?? (_, _) {},
    onWiped: onWiped ?? (_) async {},
    onHidden: onHidden ?? (_) async {},
    network: network,
  );
}

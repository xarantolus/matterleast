import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_providers.g.dart';

/// The image caches of one signed-in server.
@riverpod
Future<ServerImageCaches> serverImageCaches(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).images;

/// Whether the server proxies images from other hosts, from its stored
/// client config.
@riverpod
Stream<bool> imageProxy(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* db.watchConfigJson('client_config').map(hasImageProxy).distinct();
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connection(Ref ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
}

@Riverpod(keepAlive: true)
Stream<bool> imagesOnMobileData(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.imagesOnMobileData);

/// Whether message images load without a tap; null until the connection
/// and the setting are known.
@riverpod
bool? autoLoadImages(Ref ref) {
  final connection = ref.watch(connectionProvider).value;
  final onMobileData = ref.watch(imagesOnMobileDataProvider).value;
  if (connection == null || onMobileData == null) return null;
  return loadsImagesAutomatically(
    onMobileData: onMobileData,
    connection: connection,
  );
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:matterleast/app/data_saver.dart';
import 'package:matterleast/app/platform.dart';
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
  yield* db.watchFeatures().map((f) => f.imageProxy).distinct();
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connection(Ref ref) async* {
  final network = ref.watch(networkStateProvider);
  if (network.last case final last?) yield last;
  yield* network.reports;
}

@Riverpod(keepAlive: true)
Stream<bool> imagesOnMobileData(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.imagesOnMobileData);

@Riverpod(keepAlive: true)
Stream<bool> gifsOnMobileData(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.gifsOnMobileData);

@Riverpod(keepAlive: true)
Stream<bool> linkPicturesOnMobileData(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.linkPicturesOnMobileData);

/// Whether [kind] loads without a tap; null until the connection and the
/// settings are known. An input that fails counts as its default, so a
/// broken one never holds the app back.
@riverpod
bool? autoLoad(Ref ref, DataKind kind) {
  final connection = ref.watch(connectionProvider);
  final images = ref.watch(imagesOnMobileDataProvider);
  final gifs = ref.watch(gifsOnMobileDataProvider);
  final linkPictures = ref.watch(linkPicturesOnMobileDataProvider);
  final dataSaver = ref.watch(dataSaverProvider);
  final inputs = [connection, images, gifs, linkPictures, dataSaver];
  if (inputs.any((input) => input.isLoading)) return null;
  return loadsAutomatically(
    kind,
    connection: connection.value ?? const [],
    dataSaver: dataSaver.value ?? false,
    images: images.value ?? Settings.imagesOnMobileData.defaultValue,
    gifs: gifs.value ?? Settings.gifsOnMobileData.defaultValue,
    linkPictures:
        linkPictures.value ?? Settings.linkPicturesOnMobileData.defaultValue,
    dataSaverCoversWifi: dataSaverCoversWifi,
  );
}

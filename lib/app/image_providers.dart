import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_providers.g.dart';

/// The image caches of one signed-in server.
@riverpod
Future<ServerImageCaches> serverImageCaches(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).images;

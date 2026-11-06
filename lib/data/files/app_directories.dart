import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The app's own folders. On Linux they are readable by the owner only; on
/// Windows the profile folders already are. Android's cache folder is the
/// one the share plugin copies into.
abstract final class AppDirectories {
  static final _secured = <String>{};

  static Future<String> support() async =>
      _ownerOnly((await getApplicationSupportDirectory()).path);

  static Future<String> cache() async => _ownerOnly(
    (Platform.isAndroid
            ? await getTemporaryDirectory()
            : await getApplicationCacheDirectory())
        .path,
  );

  static Future<String> _ownerOnly(String path) async {
    if (_secured.contains(path) && Directory(path).existsSync()) return path;
    await Directory(path).create(recursive: true);
    if (Platform.isLinux) await Process.run('chmod', ['700', path]);
    _secured.add(path);
    return path;
  }
}

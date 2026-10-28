import 'dart:typed_data';

import 'package:pasteboard/pasteboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_providers.g.dart';

/// Puts an image on the system clipboard; tests swap it.
@Riverpod(keepAlive: true)
Future<void> Function(Uint8List image) imageClipboard(Ref ref) =>
    Pasteboard.writeImage;

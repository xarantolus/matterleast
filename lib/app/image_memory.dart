import 'package:flutter/widgets.dart';

const _screensOfPixels = 3;
const _bytesPerPixel = 4;

/// Image cache limits: a few screens of decoded pixels, whatever the display.
({int bytes, int images}) imageCacheBudget(Size physicalSize) {
  final bytes = (physicalSize.width * physicalSize.height * _bytesPerPixel)
      .round();
  return (bytes: bytes * _screensOfPixels, images: 200);
}

void limitImageCache(Size physicalSize) {
  final budget = imageCacheBudget(physicalSize);
  PaintingBinding.instance.imageCache
    ..maximumSizeBytes = budget.bytes
    ..maximumSize = budget.images;
}

/// Frees decoded pictures while the UI is hidden; they decode again from disk.
class ReleaseImagesWhenHidden {
  ReleaseImagesWhenHidden() {
    _listener = AppLifecycleListener(onHide: _release);
  }

  late final AppLifecycleListener _listener;

  void _release() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  void dispose() => _listener.dispose();
}

import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/image_memory.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'the budget is a few screens of pixels, so a bigger screen gets more',
    () {
      final phone = imageCacheBudget(const Size(1080, 2400));
      final tablet = imageCacheBudget(const Size(2560, 1600));
      expect(phone.bytes, 1080 * 2400 * 4 * 3);
      expect(tablet.bytes, greaterThan(phone.bytes));
    },
  );

  test('hiding the app empties the image cache', () async {
    final cache = PaintingBinding.instance.imageCache;
    final guard = ReleaseImagesWhenHidden();
    addTearDown(guard.dispose);
    final image = await createTestImage(width: 4, height: 4);
    cache.putIfAbsent('one', () {
      final completer = OneFrameImageStreamCompleter(
        Future.value(ImageInfo(image: image)),
      );
      completer.addListener(ImageStreamListener((_, _) {}));
      return completer;
    });
    await pumpEventQueue();
    expect(cache.currentSize, 1);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(cache.currentSize, 1);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

    expect(cache.currentSize, 0);
    expect(cache.liveImageCount, 0);
  });
}

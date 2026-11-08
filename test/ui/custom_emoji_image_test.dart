import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/ui/custom_emoji_image.dart';

import '../support/animated_gif.dart';
import '../support/pump_app.dart';

const _url = 'https://chat.example.test';

/// The server's emoji images: every one is [animatedGif].
class _GifService extends FileService {
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async => _GifResponse();
}

class _GifResponse implements FileServiceResponse {
  @override
  Stream<List<int>> get content => Stream.value(animatedGif);

  @override
  int? get contentLength => animatedGif.length;

  @override
  int get statusCode => 200;

  @override
  DateTime get validTill => DateTime.now().add(const Duration(days: 1));

  @override
  String? get eTag => null;

  @override
  String get fileExtension => '.gif';
}

class _GifCaches extends ServerImageCaches {
  _GifCaches()
    : super(
        directory: '',
        api: ServerApi(baseUrl: Uri.parse(_url), token: () => 'token'),
        mediaBudget: () async => 0,
        filesBudget: () async => 0,
      );

  @override
  CacheManager get identity => _emoji;

  final _emoji = CacheManager(
    Config(
      'emoji',
      repo: NonStoringObjectProvider(),
      fileSystem: MemoryCacheSystem(),
      fileService: _GifService(),
    ),
  );
}

/// How often a render object of [type] painted since the last call.
int _paints(String type) =>
    FlutterTimeline.debugCollect().getAggregated(type).count;

void main() {
  testWidgets('a new frame of an animated emoji repaints the emoji, not the '
      'text around it', (tester) async {
    final caches = _GifCaches();
    await pumpApp(
      tester,
      const Scaffold(
        body: Text.rich(
          TextSpan(
            text: 'Ship it ',
            children: [
              WidgetSpan(
                child: CustomEmojiImage(
                  serverUrl: _url,
                  emojiId: 'e1',
                  size: 20,
                  fallback: Text(':shipit:'),
                ),
              ),
            ],
          ),
        ),
      ),
      overrides: [
        serverImageCachesProvider(_url).overrideWith((ref) async => caches),
      ],
    );
    // Fetching and decoding take real time; the first shown frame paints
    // everything.
    Future<void> nextFrame() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    var emoji = 0;
    var text = 0;
    debugProfilePaintsEnabled = true;
    FlutterTimeline.debugCollectionEnabled = true;
    try {
      for (var i = 0; i < 20 && _paints('RenderImage') == 0; i++) {
        await nextFrame();
      }
      FlutterTimeline.debugReset();
      for (var i = 0; i < 5; i++) {
        await nextFrame();
        final timings = FlutterTimeline.debugCollect();
        emoji += timings.getAggregated('RenderImage').count;
        text += timings.getAggregated('RenderParagraph').count;
      }
    } finally {
      debugProfilePaintsEnabled = false;
      FlutterTimeline.debugCollectionEnabled = false;
    }

    expect(emoji, greaterThan(0));
    expect(text, 0);

    // The cache's cleanup runs 10 s after a fetch.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 11));
  });
}

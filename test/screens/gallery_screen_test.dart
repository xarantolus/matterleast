import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';

const _server = 'https://chat.example.test';

/// Answers each picture with [answer]: progress that never ends, or a file.
class _Media implements CacheManager {
  _Media(this.answer);

  final Stream<FileResponse> Function(String url) answer;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => answer(url);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Caches implements ServerImageCaches {
  _Caches(this.media);

  @override
  final CacheManager media;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Downloads implements FileDownloads {
  @override
  Uri originalUri(String fileId) => Uri.parse('$_server/api/v4/files/$fileId');

  @override
  Uri previewUri(String fileId) =>
      Uri.parse('$_server/api/v4/files/$fileId/preview');

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _photo = PostFile(
  id: 'f1',
  name: 'harbour.png',
  extension: 'png',
  mimeType: 'image/png',
  width: 400,
  height: 200,
  hasPreview: true,
);

void main() {
  Future<CacheManager> show(
    WidgetTester tester,
    Stream<FileResponse> Function(String url) answer, {
    double? tileWidth,
  }) async {
    final media = _Media(answer);
    final temp = Directory.systemTemp.createTempSync().path;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => temp,
    );
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverImageCachesProvider(_server)
              .overrideWith((ref) async => _Caches(media)),
          fileDownloadsProvider(_server)
              .overrideWith((ref) async => _Downloads()),
          imageProxyProvider(_server)
              .overrideWith((ref) => Stream.value(false)),
          autoLoadImagesProvider.overrideWith((ref) => true),
          serverSessionProvider(_server)
              .overrideWith((ref) => Completer<ServerSession>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                galleryRoute(
                  url: _server,
                  files: const [_photo],
                  initialIndex: 0,
                  heroPrefix: 'test',
                  author: 'Ada',
                  sentAt: DateTime.utc(2026, 10, 27, 9),
                  tileWidth: tileWidth,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return media;
  }

  testWidgets('a picture still loading shows a stand-in at its size and the '
      "download's progress", (tester) async {
    final progress = StreamController<FileResponse>();
    addTearDown(progress.close);
    await show(tester, (url) => progress.stream);
    progress.add(DownloadProgress('', 1000, 250));
    await tester.pump();
    await tester.pump();

    final standIn = find.byType(GalleryStandIn);
    expect(standIn, findsWidgets);
    final spinner = tester.widget<CircularProgressIndicator>(
      find.descendant(
        of: standIn.first,
        matching: find.byType(CircularProgressIndicator),
      ),
    );
    expect(spinner.value, closeTo(0.25, 0.01));
    // Where the picture will be: fitted whole into the 800 × 600 page.
    final box = tester.getSize(
      find.descendant(of: standIn.first, matching: find.byType(SizedBox)).first,
    );
    expect(box, const Size(800, 400));
  });

  testWidgets('a picture still loading shows the tile\'s own decoded picture, '
      'not a fading copy', (tester) async {
    final progress = StreamController<FileResponse>();
    addTearDown(progress.close);
    final media = await show(tester, (url) => progress.stream, tileWidth: 200);

    final standIn = find.byType(GalleryStandIn);
    final shown = tester.widget<Image>(
      find.descendant(of: standIn.first, matching: find.byType(Image)),
    );
    expect(
      shown.image,
      ResizeImage(
        CachedNetworkImageProvider(
          '$_server/api/v4/files/f1/preview',
          cacheManager: media,
        ),
        width: 200,
      ),
    );
    final page = find.byType(GalleryScreen);
    for (final fade in [
      find.byType(FadeTransition),
      find.byType(AnimatedOpacity),
      find.byType(Opacity),
    ]) {
      expect(
        find.descendant(
          of: page,
          matching: find.ancestor(of: standIn.first, matching: fade),
        ),
        findsNothing,
      );
    }
  });

  testWidgets('a picture that failed says so and offers Retry', (tester) async {
    await show(
      tester,
      (url) => Stream.error(const HttpExceptionWithStatus(404, 'Not found')),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.textContaining("The picture didn't load."), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Esc closes the gallery on a desktop', (tester) async {
    final progress = StreamController<FileResponse>();
    addTearDown(progress.close);
    await show(tester, (url) => progress.stream);
    expect(find.byType(GalleryScreen), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(GalleryScreen), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('a picture opens fitted, also after it was zoomed in before', (
    tester,
  ) async {
    final file = (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 400, 200),
        Paint()..color = const Color(0xFF336699),
      );
      final image = await recorder.endRecording().toImage(400, 200);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('${Directory.systemTemp.createTempSync().path}/a.png');
      await file.writeAsBytes(png!.buffer.asUint8List());
      return file;
    }))!;
    Stream<FileResponse> answer(String url) => Stream.value(
      FileInfo(
        const LocalFileSystem().file(file.path),
        FileSource.Online,
        DateTime(2100),
        url,
      ),
    );

    double? scale() => tester
        .state<ExtendedImageGestureState>(find.byType(ExtendedImageGesture))
        .gestureDetails
        ?.totalScale;
    Future<void> loaded() async {
      for (
        var i = 0;
        i < 20 && find.byType(ExtendedImageGesture).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await show(tester, answer);
    await loaded();
    expect(scale(), 1);
    final centre = tester.getCenter(find.byType(ExtendedImageGesture));
    await tester.tapAt(centre);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(centre);
    await tester.pumpAndSettle();
    expect(scale(), greaterThan(2));

    Navigator.of(tester.element(find.byType(GalleryScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await loaded();
    expect(scale(), 1);
  });

  test('a picture is fitted whole into the page', () {
    expect(galleryFit(_photo, const Size(800, 600)), const Size(800, 400));
    expect(
      galleryFit(const PostFile(id: 'x', name: 'x'), const Size(800, 600)),
      const Size(800, 600),
    );
  });
}

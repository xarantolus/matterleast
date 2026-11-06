import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/data_saver.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/link_preview_card.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_files.dart';

class _Downloads implements FileDownloads {
  @override
  Uri originalUri(String fileId) => Uri.parse('https://chat.test/f/$fileId');

  @override
  Uri previewUri(String fileId) =>
      Uri.parse('https://chat.test/f/$fileId/preview');

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _load(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

final _server = Uri.parse('https://chat.test');

Widget _app(
  Widget child, {
  required List<ConnectivityResult> connection,
  bool gifs = true,
  bool linkPictures = true,
  bool dataSaver = false,
}) => ProviderScope(
  overrides: <Override>[
    connectionProvider.overrideWith((ref) => Stream.value(connection)),
    dataSaverProvider.overrideWith((ref) => Stream.value(dataSaver)),
    imagesOnMobileDataProvider.overrideWith((ref) => Stream.value(true)),
    gifsOnMobileDataProvider.overrideWith((ref) => Stream.value(gifs)),
    linkPicturesOnMobileDataProvider.overrideWith(
      (ref) => Stream.value(linkPictures),
    ),
    serverImageCachesProvider(_server.toString())
        .overrideWith((ref) => Completer<ServerImageCaches>().future),
    fileDownloadsProvider(_server.toString())
        .overrideWith((ref) => Future.value(_Downloads())),
  ],
  child: MaterialApp(
    theme: themeForPlatform(MatterleastApp.lightTheme),
    home: Scaffold(
      body: PostEnvironment(
        server: _server,
        options: const ParseOptions(),
        myUsername: 'me',
        onMention: (_) {},
        onChannel: (_) {},
        onLink: (_) {},
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

const _gif = PostFile(
  id: 'g1',
  name: 'wave.gif',
  extension: 'gif',
  mimeType: 'image/gif',
  width: 300,
  height: 200,
);

Widget _gifMessage() => PostFiles(
  files: const [_gif],
  heroPrefix: 'p1',
  author: 'bob',
  sentAt: DateTime(2026),
);

const _preview = LinkPreview(
  url: 'https://docs.example.test/tide',
  title: 'Tide tables',
  siteName: 'Docs',
  description: 'When the water rises.',
  imageUrl: 'https://docs.example.test/tide.png',
  imageSize: ImageSize(width: 400, height: 300),
);

void main() {
  const mobile = [ConnectivityResult.mobile];
  const wifi = [ConnectivityResult.wifi];

  group('GIFs', () {
    testWidgets('on mobile data with GIFs off a GIF stays still until tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_gifMessage(), connection: mobile, gifs: false),
      );
      await _load(tester);
      expect(find.text('GIF'), findsOneWidget);

      await tester.tap(find.byType(MediaPicture));
      await _load(tester);
      expect(find.text('GIF'), findsNothing);
    });

    testWidgets('the tapped GIF keeps its place', (tester) async {
      await tester.pumpWidget(
        _app(_gifMessage(), connection: mobile, gifs: false),
      );
      await _load(tester);
      final before = tester.getRect(find.byType(MediaPicture));
      await tester.tap(find.byType(MediaPicture));
      await _load(tester);
      expect(tester.getRect(find.byType(MediaPicture)), before);
    });

    testWidgets('on Wi-Fi a GIF plays at once', (tester) async {
      await tester.pumpWidget(
        _app(_gifMessage(), connection: wifi, gifs: false),
      );
      await _load(tester);
      expect(find.text('GIF'), findsNothing);
    });

    testWidgets('Data Saver holds a GIF back whatever the switch says', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_gifMessage(), connection: mobile, dataSaver: true),
      );
      await _load(tester);
      expect(find.text('GIF'), findsOneWidget);
    });
  });

  group('link previews', () {
    testWidgets('on mobile data with pictures off there is no picture box', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const LinkPreviewCard(preview: _preview),
          connection: mobile,
          linkPictures: false,
        ),
      );
      await _load(tester);
      expect(find.text('Tide tables'), findsOneWidget);
      expect(find.byType(ImageSlot), findsNothing);
    });

    testWidgets('on Wi-Fi the picture shows', (tester) async {
      await tester.pumpWidget(
        _app(
          const LinkPreviewCard(preview: _preview),
          connection: wifi,
          linkPictures: false,
        ),
      );
      await _load(tester);
      expect(find.byType(ImageSlot), findsOneWidget);
    });
  });

  group('the decision', () {
    bool decide(
      DataKind kind, {
      List<ConnectivityResult> connection = mobile,
      bool dataSaver = false,
      bool images = false,
      bool gifs = false,
      bool linkPictures = false,
    }) => loadsAutomatically(
      kind,
      connection: connection,
      dataSaver: dataSaver,
      images: images,
      gifs: gifs,
      linkPictures: linkPictures,
    );

    test('each kind follows its own switch on mobile data', () {
      expect(decide(DataKind.image), isFalse);
      expect(decide(DataKind.image, images: true), isTrue);
      expect(decide(DataKind.image, gifs: true), isFalse);
      expect(decide(DataKind.gif, gifs: true), isTrue);
      expect(decide(DataKind.gif, linkPictures: true), isFalse);
      expect(decide(DataKind.linkPicture, linkPictures: true), isTrue);
      expect(decide(DataKind.linkPicture, images: true), isFalse);
    });

    test('Wi-Fi and Ethernet load everything', () {
      for (final kind in DataKind.values) {
        expect(decide(kind, connection: wifi), isTrue);
        expect(decide(kind, connection: [ConnectivityResult.ethernet]), isTrue);
        expect(
          decide(kind, connection: [ConnectivityResult.wifi, ...mobile]),
          isTrue,
        );
      }
    });

    test('Data Saver on mobile data overrides the switches', () {
      for (final kind in DataKind.values) {
        expect(
          decide(
            kind,
            dataSaver: true,
            images: true,
            gifs: true,
            linkPictures: true,
          ),
          isFalse,
        );
      }
    });

    test('Data Saver does not hold back Wi-Fi', () {
      for (final kind in DataKind.values) {
        expect(decide(kind, connection: wifi, dataSaver: true), isTrue);
      }
    });
  });
}

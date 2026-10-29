import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/clipboard_providers.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/ui/post_files.dart';

import '../support/pump_with_server.dart';

class _Transfers extends FileTransfers {
  _Transfers(this.file);

  final File file;

  @override
  Map<String, double?> build(String url) => const {};

  @override
  Future<File?> fetch(PostFile file) async => this.file;
}

class _Downloads implements FileDownloads {
  @override
  String get handoffDirectory => '';

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PostFile _file(String name, String extension, String mime) => PostFile(
  id: 'f1',
  name: name,
  extension: extension,
  mimeType: mime,
  width: 40,
  height: 20,
);

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);
  final pixels = Uint8List.fromList([1, 2, 3, 4]);
  late ServerHarness h;
  late List<Uint8List> copied;

  Future<void> show(WidgetTester tester, PostFile file) async {
    copied = [];
    final local = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('copy-image');
      return File('${dir.path}/${file.name}').writeAsBytes(pixels);
    }))!;
    addTearDown(() => local.parent.deleteSync(recursive: true));
    h = await pumpWithServer(
      tester,
      downloads: _Downloads(),
      overrides: (url) => [
        fileTransfersProvider(url).overrideWith(() => _Transfers(local)),
        imageClipboardProvider.overrideWithValue((image) async {
          copied.add(image);
        }),
      ],
      home: (url) => Scaffold(
        body: Center(
          child: FileRightClick(
            url: url,
            file: file,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 80,
                  child: Center(child: Text(file.name)),
                ),
                FileActionsMenu(url: url, file: file),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The file is read on the real clock; waits for it under load.
  Future<void> copiedBy(WidgetTester tester) async {
    for (var i = 0; i < 100 && copied.isEmpty; i++) {
      await h.settle(tester, rounds: 1);
    }
  }

  Future<void> rightClick(WidgetTester tester, Finder on) async {
    final mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await mouse.addPointer(location: tester.getCenter(on));
    addTearDown(mouse.removePointer);
    await mouse.down(tester.getCenter(on));
    await mouse.up();
    await h.settle(tester);
  }

  testWidgets('Copy image in the right-click menu puts the picture on the '
      'clipboard', (tester) async {
    await show(tester, _file('harbour.png', 'png', 'image/png'));
    await rightClick(tester, find.text('harbour.png'));
    await tester.tap(find.text('Copy image'));
    await copiedBy(tester);
    expect(copied, [pixels]);
    expect(find.text('Copied the image.'), findsOneWidget);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Copy image in the three-dot menu does the same', (tester) async {
    await show(tester, _file('harbour.png', 'png', 'image/png'));
    await tester.tap(find.byType(PopupMenuButton<MediaAction>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy image'));
    await copiedBy(tester);
    expect(copied, [pixels]);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('a file that is not an image has no Copy image', (tester) async {
    await show(tester, _file('notes.txt', 'txt', 'text/plain'));
    await rightClick(tester, find.text('notes.txt'));
    expect(find.text('Save as…'), findsOneWidget);
    expect(find.text('Copy image'), findsNothing);
    await h.close(tester);
  }, variant: desktop);
}

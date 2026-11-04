import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

final _thumbnail = find.descendant(
  of: find.byType(AttachmentStrip),
  matching: find.byType(Image),
);

Future<ServerHarness> _pasteAnImage(WidgetTester tester) async {
  final temp = Directory.systemTemp.createTempSync().path;
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => temp,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('pasteboard'),
    (call) async => call.method == 'image' ? _png : null,
  );
  addTearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    messenger.setMockMethodCallHandler(const MethodChannel('pasteboard'), null);
    Directory(temp).deleteSync(recursive: true);
  });
  final h = await pumpWithServer(
    tester,
    size: const Size(900, 700),
    platform: TargetPlatform.linux,
    handle: (_) => ok(<String, Object?>{}),
    overrides: (url) => [
      channelRightsProvider(url, channelId).overrideWith(
        (ref) => Stream.value((
          block: null,
          react: true,
          editOwn: true,
          editOthers: false,
          deleteOwn: true,
          deleteOthers: false,
          channelMentions: true,
          groupMentions: true,
        )),
      ),
    ],
    home: (url) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Composer(
          url: url,
          channelId: channelId,
          teamId: teamId,
          hint: 'Write',
        ),
      ),
    ),
  );
  await tester.tap(find.byType(TextField));
  await tester.pump();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await h.settle(tester);
  return h;
}

void main() {
  testWidgets('a pasted image shows as a thumbnail', (tester) async {
    final h = await _pasteAnImage(tester);

    expect(_thumbnail, findsOneWidget);
    await h.close(tester);
  });

  testWidgets('tapping the thumbnail opens the picture in the gallery', (
    tester,
  ) async {
    final h = await _pasteAnImage(tester);

    await tester.tap(_thumbnail, warnIfMissed: false);
    await h.settle(tester);

    expect(find.byType(GalleryScreen), findsOneWidget);
    await h.close(tester);
  });
}

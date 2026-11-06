import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/channel/composer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

class _Picker extends FilePickerPlatform {
  var opened = 0;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    opened++;
    return const [];
  }
}

Future<ServerHarness> _pumpComposer(
  WidgetTester tester, {
  ServerFeatures features = const ServerFeatures(),
}) async {
  final h = await pumpWithServer(
    tester,
    size: const Size(1200, 800),
    handle: (_) => ok(<String, Object?>{}),
    overrides: (url) => [
      featuresProvider(url).overrideWith((ref) => Stream.value(features)),
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
    home: (url) => AppShortcuts(
      child: Scaffold(
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
    ),
  );
  await tester.tap(find.byType(TextField));
  await tester.pump();
  return h;
}

Future<void> _press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

  testWidgets('Ctrl+U opens the file picker', (tester) async {
    final picker = _Picker();
    final before = FilePickerPlatform.instance;
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = before);
    final h = await _pumpComposer(tester);

    await _press(tester, LogicalKeyboardKey.keyU);
    await h.settle(tester);

    expect(picker.opened, 1);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Ctrl+U does nothing where the server takes no uploads', (
    tester,
  ) async {
    final picker = _Picker();
    final before = FilePickerPlatform.instance;
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = before);
    final h = await _pumpComposer(
      tester,
      features: const ServerFeatures(fileUploads: false),
    );

    await _press(tester, LogicalKeyboardKey.keyU);
    await h.settle(tester);

    expect(picker.opened, 0);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Ctrl+Shift+E opens the emoji picker', (tester) async {
    final h = await _pumpComposer(tester);
    expect(find.text('Search emoji'), findsNothing);

    await _press(tester, LogicalKeyboardKey.keyE, shift: true);
    await h.settle(tester);

    expect(find.text('Search emoji'), findsOneWidget);
    await h.close(tester);
  }, variant: desktop);
}

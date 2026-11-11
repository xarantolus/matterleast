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
    handle: emptyAnswer,
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

  testWidgets('pasting a URL over selected text makes a link', (tester) async {
    final h = await _pumpComposer(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? <String, Object>{'text': 'https://a.example/x'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'see the docs now',
        selection: TextSelection(baseOffset: 8, extentOffset: 12),
      ),
    );
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await h.settle(tester);

    expect(
      find.text('see the [docs](https://a.example/x) now'),
      findsOneWidget,
    );
    await h.close(tester);
  });

  Future<void> typeInto(
    WidgetTester tester,
    String text, [
    int? a,
    int? b,
  ]) async {
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: a ?? text.length,
          extentOffset: b ?? a ?? text.length,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a new line after a list item starts the next item', (
    tester,
  ) async {
    final h = await _pumpComposer(tester);
    await typeInto(tester, '- one');
    await typeInto(tester, '- one\n');
    expect(find.text('- one\n- '), findsOneWidget);
    await typeInto(tester, '- one\n- \n');
    expect(find.text('- one\n'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('typing a marker over selected text wraps it', (tester) async {
    final h = await _pumpComposer(tester);
    await typeInto(tester, 'see the docs now', 8, 12);
    await typeInto(tester, 'see the * now', 9);
    expect(find.text('see the *docs* now'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('pasting spreadsheet rows makes a table', (tester) async {
    final h = await _pumpComposer(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? <String, Object>{'text': 'a\tb\n1\t2'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _press(tester, LogicalKeyboardKey.keyV);
    await h.settle(tester);
    expect(find.text('| a | b |\n| --- | --- |\n| 1 | 2 |'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('Tab indents a list item and Shift+Tab takes it back', (
    tester,
  ) async {
    final h = await _pumpComposer(tester);
    await typeInto(tester, '- one');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.text('  - one'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(find.text('- one'), findsOneWidget);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Tab on a plain line or outside the composer moves focus', (
    tester,
  ) async {
    final h = await _pumpComposer(tester);
    final field = tester.widget<TextField>(find.byType(TextField)).focusNode!;
    await typeInto(tester, 'plain');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.text('plain'), findsOneWidget);
    expect(field.hasFocus, isFalse);
    final outside = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNot(outside));
    await h.close(tester);
  }, variant: desktop);
}

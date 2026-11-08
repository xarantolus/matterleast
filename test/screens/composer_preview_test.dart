import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_preview.dart';
import 'package:matterleast/ui/markdown/code_block.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Future<ServerHarness> _pumpComposer(WidgetTester tester) async {
  final h = await pumpWithServer(
    tester,
    size: const Size(1200, 800),
    handle: (_) => ok(<String, Object?>{}),
    overrides: (url) => [
      featuresProvider(url)
          .overrideWith((ref) => Stream.value(const ServerFeatures())),
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
      child: Builder(
        builder: (context) => Theme(
          data: isDesktop ? desktopTheme(Theme.of(context)) : Theme.of(context),
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
      ),
    ),
  );
  return h;
}

const _draft = 'Some **bold** words\n\n```\nfinal x = 1;\n```';

Future<void> _type(WidgetTester tester, ServerHarness h, String text) async {
  await tester.tap(find.byType(TextField));
  await tester.pump();
  await tester.enterText(find.byType(TextField), text);
  await h.settle(tester);
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);
  final phone = TargetPlatformVariant.only(TargetPlatform.android);

  testWidgets('the shortcut shows the draft formatted, and again toggles '
      'back to the same text', (tester) async {
    final h = await _pumpComposer(tester);
    await _type(tester, h, _draft);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await h.settle(tester);

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(CodePreview), findsOneWidget);
    expect(find.textContaining('final x = 1;'), findsWidgets);
    expect(find.text('Some **bold** words'), findsNothing);

    await tester.tap(find.text('Editing'));
    await h.settle(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(_draft), findsOneWidget);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('an empty draft previews as a hint', (tester) async {
    final h = await _pumpComposer(tester);
    await tester.tap(find.byTooltip(RegExp('Show preview')));
    await h.settle(tester);
    expect(find.text('Nothing to preview yet'), findsOneWidget);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('on a phone the Attach sheet offers Preview, and tapping the '
      'preview goes back to editing', (tester) async {
    final h = await _pumpComposer(tester);
    await _type(tester, h, _draft);

    await tester.tap(find.byTooltip('Attach'));
    await h.settle(tester);
    await tester.tap(find.text('Preview'));
    await h.settle(tester);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(CodePreview), findsOneWidget);

    await tester.tap(find.byType(ComposerPreview));
    await h.settle(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(_draft), findsOneWidget);
    await h.close(tester);
  }, variant: phone);
}

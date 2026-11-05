import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/channel/composer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Future<ServerHarness> _pumpComposer(
  WidgetTester tester, {
  ServerFeatures features = const ServerFeatures(),
}) async {
  final h = await pumpWithServer(
    tester,
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
  addTearDown(() => DesktopShell.windowFocused = true);
  await tester.tap(find.byType(TextField));
  await tester.pump();
  return h;
}

void main() {
  testWidgets('the caret blinks only while the window has the focus', (
    tester,
  ) async {
    final h = await _pumpComposer(tester);
    await tester.binding.delayed(const Duration(milliseconds: 600));
    expect(tester.binding.hasScheduledFrame, isTrue);

    DesktopShell.windowFocused = false;
    await tester.pump();
    await tester.pump();
    await tester.binding.delayed(const Duration(seconds: 2));
    expect(tester.binding.hasScheduledFrame, isFalse);

    DesktopShell.windowFocused = true;
    await tester.pump();
    await tester.binding.delayed(const Duration(milliseconds: 600));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('the caret stops blinking after 10 seconds idle', (tester) async {
    final h = await _pumpComposer(tester);
    await tester.binding.delayed(const Duration(seconds: 9));
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.binding.delayed(const Duration(seconds: 2));
    await tester.pump();
    await tester.binding.delayed(const Duration(seconds: 2));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('typing makes the caret blink again', (tester) async {
    final h = await _pumpComposer(tester);
    await tester.binding.delayed(const Duration(seconds: 12));
    await tester.pump();
    await tester.binding.delayed(const Duration(seconds: 2));
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump();
    await tester.binding.delayed(const Duration(milliseconds: 600));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  group('picking an emoji on a phone', () {
    Future<bool> pick(WidgetTester tester, {required bool typing}) async {
      final h = await _pumpComposer(tester);
      if (!typing) {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
      }
      await tester.tap(find.byTooltip('Emoji'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Flags'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('\u{1F3C1}'));
      await tester.pumpAndSettle();
      expect(find.text('\u{1F3C1}'), findsOneWidget, reason: 'inserted');
      final focused = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode
          .hasFocus;
      await h.close(tester);
      return focused;
    }

    final phone = TargetPlatformVariant.only(TargetPlatform.android);

    testWidgets('brings the keyboard back when it was up', (tester) async {
      expect(await pick(tester, typing: true), isTrue);
    }, variant: phone);

    testWidgets('leaves it down when it was down', (tester) async {
      expect(await pick(tester, typing: false), isFalse);
    }, variant: phone);
  });

  testWidgets('the + menu offers scheduling once there is a message', (
    tester,
  ) async {
    final h = await _pumpComposer(
      tester,
      features: const ServerFeatures(scheduledPosts: true),
    );
    ListTile schedule() =>
        tester.widget(find.widgetWithText(ListTile, 'Schedule message'));

    await tester.tap(find.byTooltip('Attach'));
    await tester.pumpAndSettle();
    expect(schedule().enabled, isFalse);
    expect(find.text('Write a message first'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'see you at nine');
    await tester.pump();
    await tester.tap(find.byTooltip('Attach'));
    await tester.pumpAndSettle();
    expect(schedule().enabled, isTrue);
    await h.close(tester);
  });
}

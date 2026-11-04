import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/screens/channel/composer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  testWidgets('the caret blinks only while the window has the focus', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
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
    addTearDown(() => DesktopShell.windowFocused = true);
    await tester.tap(find.byType(TextField));
    await tester.pump();
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
}

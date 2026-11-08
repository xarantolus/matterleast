import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/providers.dart';

void main() {
  testWidgets('nothing in the app moves while its window is in the '
      'background', (tester) async {
    addTearDown(() => DesktopShell.windowFocused = true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [serversProvider.overrideWith((ref) => Stream.value([]))],
        child: const MatterleastApp(),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    bool still() => MediaQuery.disableAnimationsOf(
      tester.element(find.byType(Navigator).first),
    );
    expect(still(), isFalse);

    DesktopShell.windowFocused = false;
    await tester.pump();
    expect(still(), isTrue);

    DesktopShell.windowFocused = true;
    await tester.pump();
    expect(still(), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}

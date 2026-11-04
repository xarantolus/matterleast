import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/screens/channel/composer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  testWidgets(
    'on desktop a long message grows the field to a third of the window',
    (tester) async {
      const window = Size(900, 1000);
      final h = await pumpWithServer(
        tester,
        size: window,
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
      final oneLine = tester.getSize(find.byType(TextField)).height;
      await tester.enterText(
        find.byType(TextField),
        List.filled(60, 'line').join('\n'),
      );
      await tester.pump();
      final grown = tester.getSize(find.byType(TextField)).height;
      expect(grown, greaterThan(oneLine * 6));
      expect(grown, lessThanOrEqualTo(window.height * 0.35));
      await h.close(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}

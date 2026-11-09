import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/status/status_providers.dart';

import '../support/pump_with_server.dart';
import '../support/settle.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

void main() {
  testWidgets('the open conversation says when the live connection has been '
      'down for a while, and stops when it is back', (tester) async {
    final h = await pumpWithServer(
      tester,
      overrides: (_) => [
        socketDownGraceProvider.overrideWithValue(
          const Duration(milliseconds: 400),
        ),
      ],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );
    h.server.acceptSockets = true;
    await tester.runAsync(() async {
      h.session.connection.foreground();
      await eventually(() => h.session.connection.live.value);
    });
    await h.settle(tester);
    expect(find.text('Connecting…'), findsNothing);

    // A brief drop that reconnects at once shows nothing.
    await tester.runAsync(h.server.dropSockets);
    await tester.runAsync(
      () => eventually(() => h.session.connection.live.value),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Connecting…'), findsNothing);

    // A server that stays away is announced once the delay has passed.
    h.server.acceptSockets = false;
    await tester.runAsync(h.server.dropSockets);
    await tester.pump();
    expect(find.text('Connecting…'), findsNothing);
    await settleApp(
      tester,
      until: () => find.text('Connecting…').evaluate().isNotEmpty,
    );
    expect(find.text('Connecting…'), findsOneWidget);

    h.server.acceptSockets = true;
    await tester.runAsync(
      () => eventually(() => h.session.connection.live.value),
    );
    await settleApp(
      tester,
      until: () => find.text('Connecting…').evaluate().isEmpty,
    );
    expect(find.text('Connecting…'), findsNothing);
    await h.close(tester);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/screens/calls/call_screen.dart';
import 'package:matterleast/ui/current_call_bar.dart';

import '../support/calls.dart';
import '../support/fake_call_controller.dart';
import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Widget _elsewhere(String url) => const CurrentCallBar(
  child: Scaffold(body: Center(child: Text('Elsewhere'))),
);

void main() {
  late FakeCallController calls;
  var people = <String>[];
  var config = callsConfigJson();

  setUp(() {
    calls = FakeCallController();
    people = ['ann', meId];
    config = callsConfigJson(hostControls: true);
  });

  CallConnection inCall({
    CallPhase phase = CallPhase.connected,
    bool listenOnly = false,
    CallEnd? endedBy,
  }) => CallConnection(
    phase: phase,
    channelId: channelId,
    sessionId: 's-$meId',
    muted: true,
    listenOnly: listenOnly,
    endedBy: endedBy,
    routes: const [AudioRoute.earpiece, AudioRoute.speaker],
    route: AudioRoute.earpiece,
  );

  Future<ServerHarness> open(
    WidgetTester tester, {
    Widget Function(String url)? home,
    Size? size,
  }) async {
    final h = await pumpWithServer(
      tester,
      size: size,
      trackRoutes: true,
      handle: (r) => switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok([
          callsChannelJson(channelId, call: callJson(people: people)),
        ]),
        _ => emptyAnswer(r),
      },
      seed: (session) async {
        await installCallsPlugin(session);
        await session.store.applyUsers([
          api.User.fromJson({'id': 'ann', 'username': 'ann'}),
          api.User.fromJson({'id': 'bob', 'username': 'bob'}),
        ]);
      },
      overrides: (url) {
        calls.url = url;
        return [callControllerProvider.overrideWithValue(calls)];
      },
      home: home ?? (url) => CallScreen(url: url, channelId: channelId),
    );
    // The server's address is only known now.
    calls.connectionState.value = calls.connectionState.value.copyWith(
      url: calls.url,
    );
    await h.settle(
      tester,
      until: () =>
          h.session.connection.calls.state.value.calls.isNotEmpty &&
          h.session.connection.calls.config.value != null,
    );
    return h;
  }

  testWidgets('the screen lists the people, who is host and who is muted', (
    tester,
  ) async {
    people = ['ann', meId];
    calls.connectionState.value = inCall();
    final h = await open(tester);

    expect(find.text('ann'), findsOneWidget);
    expect(find.text('Host'), findsOneWidget);
    expect(find.textContaining('(you)'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('raising the hand and muting go to the call', (tester) async {
    calls.connectionState.value = inCall();
    final h = await open(tester);

    await tester.tap(find.byTooltip('Raise hand'));
    await tester.tap(find.byTooltip('Unmute'));
    await tester.pump();

    expect(calls.hand, [true]);
    expect(calls.muting, [false]);
    await h.close(tester);
  });

  testWidgets('a hand that went up shows on its person and in the count', (
    tester,
  ) async {
    calls.connectionState.value = inCall();
    final h = await open(tester);

    h.session.connection.receive(
      const CallHandEvent(channelId, sessionId: 's-ann', raisedAt: 5),
    );
    await h.settle(tester);

    expect(find.byIcon(Icons.back_hand), findsOneWidget);
    expect(find.text('1 hand raised'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a reaction shows on the person who made it', (tester) async {
    calls.connectionState.value = inCall();
    final h = await open(tester);

    h.session.connection.receive(
      const CallReactionEvent(channelId, sessionId: 's-ann', emoji: 'clap'),
    );
    await h.settle(tester);

    expect(find.text('\u{1F44F}'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without a microphone, muting is off and says why', (
    tester,
  ) async {
    calls.connectionState.value = inCall(listenOnly: true);
    final h = await open(tester);

    await tester.tap(find.byTooltip('No microphone access'));
    expect(calls.muting, isEmpty);
    await h.close(tester);
  });

  testWidgets('the audio output can be picked from what the phone has', (
    tester,
  ) async {
    calls.connectionState.value = inCall();
    final h = await open(tester);

    await tester.tap(find.byTooltip('Audio output'));
    await tester.pumpAndSettle();

    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the host can remove someone, after asking', (tester) async {
    people = [meId, 'ann'];
    calls.connectionState.value = inCall();
    final h = await open(tester);

    await tester.tap(find.byTooltip('Manage ann'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from call'));
    await tester.pumpAndSettle();
    expect(h.server.paths.where((p) => p.endsWith('/host/remove')), isEmpty);
    await tester.tap(find.text('Remove'));
    await h.settle(
      tester,
      until: () => h.server.paths.any((p) => p.endsWith('/host/remove')),
    );

    final sent = h.server.seen.singleWhere(
      (r) => r.path.endsWith('/host/remove'),
    );
    expect(sent.path, '$callsRoute/calls/$channelId/host/remove');
    expect(sent.body, {'session_id': 's-ann'});
    await h.close(tester);
  });

  testWidgets('someone who is not the host gets no host controls', (
    tester,
  ) async {
    people = ['ann', meId];
    calls.connectionState.value = inCall();
    final h = await open(tester);

    expect(find.byTooltip('Manage ann'), findsNothing);
    expect(find.byTooltip('Host controls'), findsNothing);
    await h.close(tester);
  });

  testWidgets('host controls stay away where the server does not allow them', (
    tester,
  ) async {
    config = callsConfigJson();
    people = [meId, 'ann'];
    calls.connectionState.value = inCall();
    final h = await open(tester);

    expect(find.byTooltip('Manage ann'), findsNothing);
    await h.close(tester);
  });

  testWidgets('the host ends the call for everyone, after asking', (
    tester,
  ) async {
    people = [meId, 'ann'];
    calls.connectionState.value = inCall();
    final h = await open(tester);

    await tester.tap(find.byTooltip('Host controls'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End call for everyone'));
    await tester.pumpAndSettle();
    expect(h.server.paths, isNot(contains('$callsRoute/calls/$channelId/end')));
    await tester.tap(find.text('End call'));
    await h.settle(
      tester,
      until: () => h.server.paths.contains('$callsRoute/calls/$channelId/end'),
    );

    expect(h.server.paths, contains('$callsRoute/calls/$channelId/end'));
    await h.close(tester);
  });

  testWidgets('an ended call says so and only offers Close', (tester) async {
    calls.connectionState.value = inCall(
      phase: CallPhase.ended,
      endedBy: CallEnd.ended,
    );
    final h = await open(tester);

    expect(find.text('Call ended'), findsWidgets);
    expect(find.text('Close'), findsOneWidget);
    expect(find.byTooltip('Mute'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a failed call says why and can be retried', (tester) async {
    calls.connectionState.value = CallConnection(
      phase: CallPhase.failed,
      channelId: channelId,
      failure: const CallFailure(CallFailureKind.media, 'No audio path'),
    );
    final h = await open(tester);

    expect(find.text('No audio path'), findsWidgets);
    await tester.tap(find.text('Retry'));
    expect(calls.joined, [channelId]);
    await h.close(tester);
  });

  testWidgets('the bar shows on other screens while in a call', (tester) async {
    calls.connectionState.value = inCall();
    final h = await open(tester, home: _elsewhere);

    expect(find.text('Elsewhere'), findsOneWidget);
    expect(find.text('In the call · muted'), findsOneWidget);
    expect(find.byTooltip('Leave call'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the bar is gone while no call runs', (tester) async {
    final h = await open(tester, home: _elsewhere);

    expect(find.byTooltip('Leave call'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a call that ended shows in the bar until dismissed', (
    tester,
  ) async {
    calls.connectionState.value = inCall(
      phase: CallPhase.ended,
      endedBy: CallEnd.removed,
    );
    final h = await open(tester, home: _elsewhere);

    expect(find.text('You were removed from the call'), findsOneWidget);
    expect(find.byTooltip('Dismiss'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the screen holds on a wide window at the largest text', (
    tester,
  ) async {
    calls.connectionState.value = inCall();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = await open(tester, size: const Size(1600, 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('ann'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the bar holds its text at the largest text size', (
    tester,
  ) async {
    calls.connectionState.value = inCall();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = await open(tester, home: _elsewhere);

    expect(tester.takeException(), isNull);
    expect(find.text('In the call · muted'), findsOneWidget);
    expect(find.text('Elsewhere'), findsOneWidget);
    await h.close(tester);
  });
}

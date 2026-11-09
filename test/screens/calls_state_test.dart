import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';

import '../support/calls.dart';
import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

class _FakeCalls implements CallController {
  @override
  final current = ValueNotifier<CallRef?>(null);
  final joined = <String>[];
  final started = <String>[];

  @override
  Future<void> join(String url, String channelId) async =>
      joined.add(channelId);

  @override
  Future<void> start(
    String url,
    String channelId, {
    String? title,
    String? rootId,
  }) async => started.add(channelId);
}

const _postId = 'cp000000000000000000000p01';

Future<void> _seed(
  ServerSession session, {
  String type = 'O',
  bool ended = false,
}) async {
  await installCallsPlugin(session);
  await session.store.applyChannels(
    channels: [
      api.Channel.fromJson({
        'id': channelId,
        'team_id': teamId,
        'type': type,
        'name': 'boats',
        'display_name': 'Boats',
        'total_msg_count': 1,
      }),
    ],
    members: const [],
  );
  await session.store.applyChannelPage(
    channelId: channelId,
    page: api.PostList.fromJson({
      'order': [_postId],
      'posts': {
        _postId: {
          'id': _postId,
          'channel_id': channelId,
          'user_id': 'someone',
          'create_at': DateTime.utc(2026, 10, 26, 8).millisecondsSinceEpoch,
          'type': 'custom_calls',
          'message': '',
          'props': {
            'start_at': DateTime.utc(2026, 10, 26, 8).millisecondsSinceEpoch,
            'end_at': ended
                ? DateTime.utc(2026, 10, 26, 8, 5).millisecondsSinceEpoch
                : 0,
          },
        },
      },
    }),
    kind: PageKind.page,
    requested: 1,
  );
}

void main() {
  late _FakeCalls calls;
  var channels = <Object?>[];
  var config = callsConfigJson();

  setUp(() {
    calls = _FakeCalls();
    config = callsConfigJson();
    channels = [
      callsChannelJson(
        channelId,
        call: callJson(postId: _postId, people: ['ann', 'bob']),
      ),
    ];
  });

  Future<ServerHarness> open(
    WidgetTester tester, {
    bool withController = true,
    String type = 'O',
    bool ended = false,
  }) async {
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok(channels),
        _ => emptyAnswer(r),
      },
      seed: (session) => _seed(session, type: type, ended: ended),
      overrides: (url) => [
        if (withController) callControllerProvider.overrideWithValue(calls),
      ],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );
    await h.settle(
      tester,
      until: () =>
          h.session.connection.calls.config.value != null &&
          (channels.isEmpty ||
              h.session.connection.calls.state.value.calls.isNotEmpty),
    );
    return h;
  }

  testWidgets('a running call shows in a banner and on its post', (
    tester,
  ) async {
    final h = await open(tester);

    expect(find.text('Call in progress · 2'), findsOneWidget);
    expect(find.text('Call started'), findsOneWidget);
    expect(find.text('Join'), findsNWidgets(2));
    await h.close(tester);
  });

  testWidgets('when the call ends the banner goes and the post says so', (
    tester,
  ) async {
    final h = await open(tester);

    h.session.connection.receive(const CallEndedEvent(channelId));
    await h.settle(tester);

    expect(find.textContaining('Call in progress'), findsNothing);
    expect(find.text('Call started'), findsNothing);
    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('Join'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a post of a call that ended says how long it lasted', (
    tester,
  ) async {
    channels = [];
    final h = await open(tester, ended: true);

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.textContaining('Lasted 5 minutes'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without a way to join, a call is shown but not joinable', (
    tester,
  ) async {
    final h = await open(tester, withController: false);

    expect(find.text('Call in progress · 2'), findsOneWidget);
    expect(find.text('Join'), findsNothing);
    expect(find.byTooltip('Join call'), findsNothing);
    await h.close(tester);
  });

  testWidgets('Join in the banner joins the call of the channel', (
    tester,
  ) async {
    final h = await open(tester);

    await tester.tap(find.text('Join').first);
    await tester.pump();

    expect(calls.joined, [channelId]);
    await h.close(tester);
  });

  testWidgets('the app bar joins a running call', (tester) async {
    final h = await open(tester);

    await tester.tap(find.byTooltip('Join call'));
    await tester.pump();

    expect(calls.joined, [channelId]);
    expect(find.byTooltip('Start call'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a channel without a call offers to start one', (tester) async {
    channels = [callsChannelJson(channelId)];
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok(channels),
        _ => emptyAnswer(r),
      },
      seed: (session) => _seed(session),
      overrides: (url) => [callControllerProvider.overrideWithValue(calls)],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );
    await h.settle(
      tester,
      until: () => h.session.connection.calls.config.value != null,
    );

    await tester.tap(find.byTooltip('Start call'));
    await tester.pump();

    expect(calls.started, [channelId]);
    expect(find.textContaining('Call in progress'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a channel with calls switched off offers nothing', (
    tester,
  ) async {
    channels = [callsChannelJson(channelId, enabled: false)];
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok(channels),
        _ => emptyAnswer(r),
      },
      seed: (session) => _seed(session),
      overrides: (url) => [callControllerProvider.overrideWithValue(calls)],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );
    await h.settle(
      tester,
      until: () => h.session.connection.calls.state.value.enabled.isNotEmpty,
    );

    expect(find.byTooltip('Start call'), findsNothing);
    expect(find.byTooltip('Join call'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a group channel offers nothing where groups may not call', (
    tester,
  ) async {
    config = callsConfigJson(groupCallsAllowed: false);
    channels = [callsChannelJson(channelId)];
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '$callsRoute/config' => ok(config),
        '$callsRoute/channels' => ok(channels),
        _ => emptyAnswer(r),
      },
      seed: (session) => _seed(session),
      overrides: (url) => [callControllerProvider.overrideWithValue(calls)],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );
    await h.settle(
      tester,
      until: () => h.session.connection.calls.config.value != null,
    );

    expect(find.byTooltip('Start call'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a server without the plugin shows nothing of calls', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      handle: emptyAnswer,
      seed: (session) async {
        await _seed(session);
        await session.store.applyPlugins(const []);
      },
      overrides: (url) => [callControllerProvider.overrideWithValue(calls)],
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );

    expect(find.byTooltip('Start call'), findsNothing);
    expect(find.textContaining('Call in progress'), findsNothing);
    await h.close(tester);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/rtc_call_controller.dart';
import 'package:matterleast/domain/call_connection.dart';

import '../support/calls.dart';
import '../support/fake_call.dart';
import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

void main() {
  late RtcCallController controller;
  late FakeCallPlatform platform;
  late List<FakeLine> lines;
  late List<FakePeer> peers;
  const channel = CallHarness.channel;

  setUp(() async {
    final (server, session) = await startServerSession();
    server.handle = (request) => switch (request.path) {
      '$callsRoute/config' => ok(callsConfigJson()),
      _ => emptyAnswer(request),
    };
    platform = FakeCallPlatform();
    lines = [];
    peers = [];
    final log = <String>[];
    controller = RtcCallController(
      sessionOf: (_) async => session,
      platform: platform,
      createPeer: () {
        final peer = FakePeer(log);
        peers.add(peer);
        return peer;
      },
      lineOpener: (_) =>
          ({
            required connectionId,
            required expected,
            required originalId,
          }) async {
            final line = FakeLine(log, connectionId: 'conn1');
            lines.add(line);
            return line;
          },
    );
    addTearDown(() async {
      await controller.dispose();
      await platform.close();
    });
  });

  Future<void> connected() async {
    await eventually(() => lines.isNotEmpty);
    lines.last.emit(const LineHello('conn1'));
    await eventually(() => lines.last.actions.contains('join'));
    lines.last.emit(const LineJoined());
    await eventually(() => peers.last.offers.isNotEmpty);
  }

  test(
    'while a call runs it is the current one, and joining another waits',
    () async {
      expect(controller.current.value, isNull);
      await controller.join('https://chat.example', channel);
      expect(controller.current.value, (
        url: 'https://chat.example',
        channelId: channel,
      ));
      await connected();
      expect(controller.connection.value.url, 'https://chat.example');
      expect(controller.connection.value.channelId, channel);
      expect(controller.connection.value.phase, CallPhase.connecting);

      await controller.join('https://chat.example', 'other');
      await afterWork();
      expect(peers, hasLength(1));
      expect(controller.current.value?.channelId, channel);
    },
  );

  test('leaving ends it, and leaving again clears how it ended', () async {
    await controller.join('https://chat.example', channel);
    await connected();
    await controller.leave();
    expect(controller.current.value, isNull);
    expect(controller.connection.value.endedBy, CallEnd.left);
    expect(lines.last.actions, contains('leave'));

    await controller.leave();
    expect(controller.connection.value, const CallConnection());
  });

  test('a call that failed can be joined again', () async {
    await controller.join('https://chat.example', channel);
    await eventually(() => lines.isNotEmpty);
    lines.last
      ..emit(const LineHello('conn1'))
      ..emit(const LineError('forbidden'));
    await eventually(
      () => controller.connection.value.phase == CallPhase.failed,
    );
    expect(controller.connection.value.failure?.message, 'forbidden');
    expect(controller.current.value, isNull);

    await controller.join('https://chat.example', channel);
    expect(controller.current.value?.channelId, channel);
    await eventually(() => lines.length == 2);
  });

  test('muting before there is a call does nothing', () async {
    await controller.setMuted(muted: false);
    expect(controller.connection.value.muted, isTrue);
  });
}

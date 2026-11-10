import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/calls/msgpack.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/calls/call_line.dart';

import '../support/fake_socket_server.dart';
import '../support/wait.dart';

const _prefix = 'custom_com.mattermost.calls_';

void main() {
  late FakeSocketServer server;
  setUp(() async => server = await FakeSocketServer.start());
  tearDown(() => server.close());

  Future<(CallSocket, List<LineEvent>)> open({
    String connectionId = '',
    int expected = 0,
    String originalId = '',
  }) async {
    final socket = await CallSocket.open(
      serverUrl: server.url,
      token: () => 'secret-token',
      connectionId: connectionId,
      expected: expected,
      originalId: originalId,
    );
    final events = <LineEvent>[];
    socket.events.listen(events.add);
    await eventually(() => server.connections.isNotEmpty);
    return (socket, events);
  }

  test('connects as a calls socket with the token and resume ids', () async {
    final (socket, _) = await open(connectionId: 'old', expected: 7);
    final connection = server.connections.single;
    expect(connection.uri.queryParameters, {
      'calls': 'true',
      'connection_id': 'old',
      'sequence_number': '7',
    });
    expect(connection.headers.value('authorization'), 'Bearer secret-token');
    await socket.close();
  });

  test('sends actions as JSON text and SDP as a MessagePack frame', () async {
    final (socket, _) = await open();
    final action = server.actions.first;
    socket.send('join', {'channelID': 'c1'});
    final sent = await action;
    expect(sent['action'], '${_prefix}join');
    expect(sent['data'], {'channelID': 'c1'});
    expect(sent['seq'], 1);

    socket.sendSdp('{"type":"offer","sdp":"x"}');
    await eventually(() => server.binary.isNotEmpty);
    final frame =
        PackReader(server.binary.single).read()! as Map<String, Object?>;
    expect(frame['action'], '${_prefix}sdp');
    expect(frame['seq'], 2);
    await socket.close();
  });

  test(
    'says hello, then what is addressed to it, and ignores the rest',
    () async {
      final (socket, events) = await open();
      server.event('hello', 0, {'connection_id': 'conn9'});
      await eventually(() => events.isNotEmpty);
      expect((events.single as LineHello).connectionId, 'conn9');
      expect(socket.connectionId, 'conn9');
      expect(socket.expected, 1);

      server
        ..event('${_prefix}join', 1, {'connID': 'someone else'})
        ..event('${_prefix}join', 2, {'connID': 'conn9'})
        ..event('${_prefix}signal', 3, {
          'connID': 'conn9',
          'data': '{"type":"offer"}',
        })
        ..event('${_prefix}error', 4, {'connID': 'conn9', 'data': 'forbidden'})
        ..event(
          '${_prefix}user_muted',
          5,
          {'userID': 'u1', 'session_id': 's1'},
          broadcast: {'channel_id': 'c1'},
        );
      await eventually(() => events.length >= 5);
      expect(events[1], isA<LineJoined>());
      expect((events[2] as LineSignal).data, '{"type":"offer"}');
      expect((events[3] as LineError).message, 'forbidden');
      expect(((events[4] as LineCall).event as CallMutedEvent).sessionId, 's1');
      expect(socket.expected, 6);
      await socket.close();
    },
  );

  test('answers to the first connection id count after a reconnect', () async {
    final (socket, events) = await open(
      connectionId: 'old',
      originalId: 'orig',
    );
    server
      ..event('hello', 0, {'connection_id': 'new'})
      ..event('${_prefix}error', 1, {
        'connID': 'orig',
        'data': 'no call ongoing',
      });
    await eventually(() => events.length >= 2);
    expect((events[1] as LineError).message, 'no call ongoing');
    await socket.close();
  });

  test(
    'a resumed socket that gets no hello still names its connection',
    () async {
      final (socket, _) = await open(connectionId: 'old', expected: 7);
      expect(socket.connectionId, 'old');
      expect(socket.expected, 7);
      await socket.close();
    },
  );

  test('sends reconnect once', () async {
    final (socket, _) = await open();
    final actions = <Map<String, Object?>>[];
    final sub = server.actions.listen(actions.add);
    socket
      ..sendReconnect(channelId: 'c', originalId: 'o', previousId: 'p')
      ..sendReconnect(channelId: 'c', originalId: 'o', previousId: 'p');
    await eventually(() => actions.isNotEmpty);
    await afterWork();
    expect(actions, hasLength(1));
    expect(actions.single['data'], {
      'channelID': 'c',
      'originalConnID': 'o',
      'prevConnID': 'p',
    });
    await sub.cancel();
    await socket.close();
  });

  test('a check is answered by anything the server says', () async {
    final (socket, _) = await open();
    final asked = server.actions.first;
    final check = socket.check('c1', const Duration(seconds: 5));
    expect((await asked)['action'], '${_prefix}call_state');
    server.event('${_prefix}call_end', 1, {'channelID': 'c1'});
    expect(await check, isTrue);
    await socket.close();
  });

  test('a check fails when the server stays silent', () async {
    final (socket, _) = await open();
    expect(await socket.check('c1', const Duration(milliseconds: 50)), isFalse);
    await socket.close();
  });

  test('tells when the server closes the socket', () async {
    final (socket, events) = await open();
    await server.connections.single.socket.close();
    await eventually(() => events.any((e) => e is LineClosed));
    await socket.close();
  });
}

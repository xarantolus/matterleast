import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A loopback WebSocket endpoint at `/api/v4/websocket` standing in for a
/// Mattermost server. Every connection is kept with the request that opened
/// it; actions the client sends arrive on [actions].
class FakeSocketServer {
  FakeSocketServer._(this._server);

  final HttpServer _server;
  final connections = <({Uri uri, HttpHeaders headers, WebSocket socket})>[];
  final _actions = StreamController<Map<String, Object?>>.broadcast();
  final _connected = StreamController<void>.broadcast();

  /// Answer `ping` actions with a pong, as the server does.
  var answerPings = true;
  var _closing = false;

  static Future<FakeSocketServer> start() async {
    final fake = FakeSocketServer._(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    fake._server.listen(fake._serve);
    return fake;
  }

  Uri get url => Uri.parse('http://127.0.0.1:${_server.port}');

  Stream<Map<String, Object?>> get actions => _actions.stream;

  Future<void> nextConnection() => _connected.stream.first;

  Future<void> _serve(HttpRequest request) async {
    if (request.uri.path != '/api/v4/websocket') {
      request.response.statusCode = 404;
      await request.response.close();
      return;
    }
    connections.add((
      uri: request.uri,
      headers: request.headers,
      socket: await WebSocketTransformer.upgrade(request),
    ));
    _connected.add(null);
    _answer(connections.last.socket);
  }

  void _answer(WebSocket socket) {
    socket.listen((message) {
      final json = jsonDecode(message as String) as Map<String, Object?>;
      _actions.add(json);
      if (json['action'] == 'ping' &&
          answerPings &&
          !_closing &&
          socket.readyState == WebSocket.open) {
        socket.add(
          jsonEncode({
            'status': 'OK',
            'seq_reply': json['seq'],
            'data': {'text': 'pong'},
          }),
        );
      }
    });
  }

  void send(Map<String, Object?> frame) =>
      connections.last.socket.add(jsonEncode(frame));

  /// Sends an event with the given sequence number.
  void event(
    String name,
    int seq,
    Map<String, Object?> data, {
    Map<String, Object?> broadcast = const {},
  }) => send({'event': name, 'data': data, 'broadcast': broadcast, 'seq': seq});

  Future<void> close() async {
    _closing = true;
    for (final c in connections) {
      await c.socket.close();
    }
    await _server.close(force: true);
    await _actions.close();
    await _connected.close();
  }
}

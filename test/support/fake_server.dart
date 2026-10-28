import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A request the fake server received, with its body read and decoded.
class SeenRequest {
  SeenRequest(this.raw, this.body, [this.json, this.text = '']);

  /// The body as text, such as a multipart upload.
  final String text;

  final HttpRequest raw;
  final Map<String, Object?> body;

  /// The decoded body whatever its shape, such as a list of names.
  final Object? json;

  String get method => raw.method;
  String get path => raw.uri.path;
  String? header(String name) => raw.headers.value(name);
}

typedef Reply = ({int status, Object? json, Map<String, String> headers});

Reply ok(Object? json, {Map<String, String> headers = const {}}) =>
    (status: 200, json: json, headers: headers);

Reply error(int status, String id) => (
  status: status,
  json: {'id': id, 'message': id, 'status_code': status},
  headers: const {},
);

/// A loopback HTTP server that answers each request with [handle], standing
/// in for a Mattermost server.
class FakeServer {
  FakeServer._(this._server);

  final HttpServer _server;
  final seen = <SeenRequest>[];

  /// Return null to never answer (a server that hangs).
  FutureOr<Reply?> Function(SeenRequest request) handle = (_) =>
      error(404, 'not_found');

  static Future<FakeServer> start() async {
    final fake = FakeServer._(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    fake._server.listen(fake._serve);
    return fake;
  }

  Uri get url => Uri.parse('http://127.0.0.1:${_server.port}');

  Iterable<String> get paths => seen.map((r) => r.path);

  /// Accept WebSocket connections at `/api/v4/websocket` and answer their
  /// pings, so a session's socket connects as to a real server.
  var acceptSockets = false;
  final sockets = <WebSocket>[];

  /// Sends [frame] on every open WebSocket.
  void sendToSockets(Map<String, Object?> frame) {
    for (final socket in sockets) {
      socket.add(jsonEncode(frame));
    }
  }

  /// Closes every open WebSocket, as a server that went away would.
  Future<void> dropSockets() async {
    for (final socket in [...sockets]) {
      await socket.close();
    }
    sockets.clear();
  }

  Future<void> _serve(HttpRequest raw) async {
    if (acceptSockets &&
        raw.uri.path == '/api/v4/websocket' &&
        WebSocketTransformer.isUpgradeRequest(raw)) {
      final socket = await WebSocketTransformer.upgrade(raw);
      sockets.add(socket);
      socket.listen((message) {
        final json = jsonDecode(message as String) as Map<String, Object?>;
        if (json['action'] != 'ping') return;
        try {
          socket.add(
            jsonEncode({
              'status': 'OK',
              'seq_reply': json['seq'],
              'data': {'text': 'pong'},
            }),
          );
        } on StateError {
          return;
        }
      }, onDone: () => sockets.remove(socket));
      return;
    }
    final bytes = await raw.fold<List<int>>(
      [],
      (all, part) => all..addAll(part),
    );
    final text = utf8.decode(bytes, allowMalformed: true);
    final decoded = raw.headers.contentType?.mimeType == 'multipart/form-data'
        ? null
        : text.isEmpty
        ? null
        : jsonDecode(text);
    final request = SeenRequest(
      raw,
      decoded is Map<String, Object?> ? decoded : const {},
      decoded,
      text,
    );
    seen.add(request);
    final reply = await handle(request);
    if (reply == null) return;
    raw.response.statusCode = reply.status;
    reply.headers.forEach(raw.response.headers.set);
    final json = reply.json;
    if (json is String) {
      raw.response.headers.contentType = ContentType.html;
      raw.response.write(json);
    } else {
      raw.response.headers.contentType = ContentType.json;
      raw.response.write(jsonEncode(json));
    }
    await raw.response.close();
  }

  Future<void> close() async {
    await dropSockets();
    await _server.close(force: true);
  }
}

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

Map<String, Object?> fixtureMap(String name) =>
    fixture(name)! as Map<String, Object?>;

/// Answers the three calls of a server check like the local test server.
Reply? mattermostProbe(SeenRequest request, {String prefix = ''}) =>
    switch (request.path.substring(prefix.length)) {
      '/api/v4/system/ping' => ok({'status': 'OK'}),
      '/api/v4/config/client' => ok(fixtureMap('client_config')),
      '/api/v4/license/client' => ok(fixtureMap('client_license')),
      _ => error(404, 'not_found'),
    };

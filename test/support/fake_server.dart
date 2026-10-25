import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A request the fake server received, with its body read and decoded.
class SeenRequest {
  SeenRequest(this.raw, this.body);

  final HttpRequest raw;
  final Map<String, Object?> body;

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

  Future<void> _serve(HttpRequest raw) async {
    final text = await utf8.decodeStream(raw);
    final decoded = text.isEmpty ? null : jsonDecode(text);
    final request = SeenRequest(
      raw,
      decoded is Map<String, Object?> ? decoded : const {},
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

  Future<void> close() => _server.close(force: true);
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

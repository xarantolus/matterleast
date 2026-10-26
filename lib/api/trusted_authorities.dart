import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:matterleast/domain/ca_certificate.dart';
import 'package:matterleast/log.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Certificate authorities the user chose to trust, one per server origin,
/// on top of the system's roots. Kept as PEM files under app support, read
/// once per isolate before the first connection.
class TrustedAuthorities {
  TrustedAuthorities(this._directory);

  static final instance = TrustedAuthorities(
    () async =>
        p.join((await getApplicationSupportDirectory()).path, 'trusted_ca'),
  );

  final Future<String> Function() _directory;
  final _pems = <String, String>{};
  Future<void>? _loading;
  int _version = 0;

  /// Changes whenever a CA is added or removed, so clients can rebuild.
  int get version => _version;

  Future<void> get ready => _loading ??= _load();

  String? pemFor(Uri server) => _pems[server.origin];

  /// A client for [server] that also trusts its CA, if the user added one.
  HttpClient httpClient(Uri server) {
    final pem = _pems[server.origin];
    return pem == null ? HttpClient() : HttpClient(context: trusting(pem));
  }

  /// Validates [ca] with the TLS stack, then stores it for [server].
  Future<void> trust(Uri server, CaCertificate ca) async {
    trusting(ca.pem);
    await ready;
    final dir = Directory(await _directory());
    await dir.create(recursive: true);
    await File(p.join(dir.path, _fileName(server))).writeAsString(ca.pem);
    _pems[server.origin] = ca.pem;
    _version++;
  }

  Future<void> forget(Uri server) async {
    await ready;
    if (_pems.remove(server.origin) == null) return;
    _version++;
    final file = File(p.join(await _directory(), _fileName(server)));
    if (file.existsSync()) await file.delete();
  }

  Future<void> _load() async {
    try {
      final dir = Directory(await _directory());
      if (!dir.existsSync()) return;
      await for (final entry in dir.list()) {
        if (entry is! File || !entry.path.endsWith('.pem')) continue;
        final name = p.basenameWithoutExtension(entry.path);
        try {
          final origin = utf8.decode(base64Url.decode(name));
          _pems[origin] = await entry.readAsString();
        } on FormatException {
          Log.warn('tls', 'Skipped an unreadable trusted CA file');
        }
      }
      if (_pems.isNotEmpty) _version++;
    } on Object catch (e) {
      Log.warn('tls', 'Reading trusted CAs failed', e);
    }
  }

  static String _fileName(Uri server) =>
      '${base64Url.encode(utf8.encode(server.origin))}.pem';
}

/// The system's roots plus [pem]; throws a [TlsException] when the TLS
/// stack can't read it.
SecurityContext trusting(String pem) =>
    SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(Uint8List.fromList(utf8.encode(pem)));

/// Dio transport for one server that waits for the trusted CAs and builds
/// a new client when they change.
class TrustingAdapter implements HttpClientAdapter {
  TrustingAdapter(this._server, [TrustedAuthorities? authorities])
    : _authorities = authorities ?? TrustedAuthorities.instance;

  final Uri _server;
  final TrustedAuthorities _authorities;
  IOHttpClientAdapter? _inner;
  int _version = -1;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await _authorities.ready;
    if (_inner == null || _version != _authorities.version) {
      _inner?.close();
      _version = _authorities.version;
      _inner = IOHttpClientAdapter(
        createHttpClient: () => _authorities.httpClient(_server),
      );
    }
    return _inner!.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) => _inner?.close(force: force);
}

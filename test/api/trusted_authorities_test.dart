import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/trusted_authorities.dart';
import 'package:matterleast/domain/ca_certificate.dart';
import 'package:path/path.dart' as p;

/// A private CA and a server certificate it signed for 127.0.0.1, made
/// with openssl for each run.
Future<Directory> _makeCertificates() async {
  final dir = await Directory.systemTemp.createTemp('trusted_ca_test');
  Future<void> run(List<String> args) async {
    final result = await Process.run(
      'openssl',
      args,
      workingDirectory: dir.path,
    );
    if (result.exitCode != 0) throw StateError('openssl: ${result.stderr}');
  }

  await run([
    'req', '-x509', '-newkey', 'rsa:2048', '-nodes', '-days', '30', //
    '-keyout', 'ca.key', '-out', 'ca.pem',
    '-subj', '/O=Invented Test Org/CN=Invented Test Root',
  ]);
  await run([
    'req', '-newkey', 'rsa:2048', '-nodes', '-keyout', 'leaf.key', //
    '-out', 'leaf.csr', '-subj', '/CN=127.0.0.1',
  ]);
  File(p.join(dir.path, 'san.ext'))
      .writeAsStringSync('subjectAltName=IP:127.0.0.1\n');
  await run([
    'x509', '-req', '-in', 'leaf.csr', '-CA', 'ca.pem', '-CAkey', 'ca.key', //
    '-CAcreateserial', '-days', '30', '-out', 'leaf.pem',
    '-extfile', 'san.ext',
  ]);
  await run(['x509', '-in', 'ca.pem', '-outform', 'DER', '-out', 'ca.der']);
  return dir;
}

void main() {
  late Directory certs;
  late HttpServer server;
  late Uri url;

  setUpAll(() async {
    certs = await _makeCertificates();
    final context = SecurityContext()
      ..useCertificateChain(p.join(certs.path, 'leaf.pem'))
      ..usePrivateKey(p.join(certs.path, 'leaf.key'));
    server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    server.listen((request) {
      request.response
        ..headers.contentType = ContentType.json
        ..write('{"status":"OK"}');
      unawaited(request.response.close());
    });
    url = Uri.parse('https://127.0.0.1:${server.port}');
  });

  tearDownAll(() async {
    await server.close(force: true);
    certs.deleteSync(recursive: true);
  });

  CaCertificate readCa(String name) =>
      parseCaCertificate(File(p.join(certs.path, name)).readAsBytesSync())!;

  group('reading a CA file', () {
    test('shows subject, validity and the SHA-256 fingerprint', () async {
      final ca = readCa('ca.pem');
      final openssl = await Process.run('openssl', [
        'x509', '-in', p.join(certs.path, 'ca.pem'), '-noout', //
        '-fingerprint', '-sha256',
      ]);
      final expected = openssl.stdout.toString().trim().split('=').last;
      expect(ca.subject, 'CN=Invented Test Root, O=Invented Test Org');
      expect(ca.fingerprint, expected);
      expect(ca.notAfter.difference(ca.notBefore).inDays, 30);
    });

    test('reads DER like PEM', () {
      final der = readCa('ca.der');
      final pem = readCa('ca.pem');
      expect(der.fingerprint, pem.fingerprint);
      expect(der.subject, pem.subject);
      expect(der.pem.replaceAll('\n', ''), pem.pem.replaceAll('\n', ''));
    });

    test('keeps every certificate of a PEM bundle', () {
      final bundle =
          File(p.join(certs.path, 'ca.pem')).readAsStringSync() +
          File(p.join(certs.path, 'leaf.pem')).readAsStringSync();
      final ca = parseCaCertificate(Uint8List.fromList(bundle.codeUnits))!;
      expect('BEGIN CERTIFICATE'.allMatches(ca.pem), hasLength(2));
      expect(ca.subject, 'CN=Invented Test Root, O=Invented Test Org');
    });

    test('rejects files that are not certificates', () {
      expect(parseCaCertificate(Uint8List.fromList('hello'.codeUnits)), null);
      expect(parseCaCertificate(Uint8List(0)), null);
      const broken =
          '-----BEGIN CERTIFICATE-----\nAAAA\n-----END CERTIFICATE-----\n';
      expect(parseCaCertificate(Uint8List.fromList(broken.codeUnits)), null);
    });
  });

  group('connecting to a server with a private CA', () {
    late Directory store;
    setUp(() => store = Directory.systemTemp.createTempSync('trusted_ca'));
    tearDown(() => store.deleteSync(recursive: true));

    ServerApi apiWith(TrustedAuthorities authorities) => ServerApi(
      baseUrl: url,
      token: () => null,
      dio: Dio()..httpClientAdapter = TrustingAdapter(url, authorities),
    );

    Future<Object?> ping(ServerApi api) =>
        api.getJsonObject('/api/v4/system/ping');

    test('fails as untrusted until the CA is trusted, then connects', () async {
      final authorities = TrustedAuthorities(() async => store.path);
      final api = apiWith(authorities);
      await expectLater(ping(api), throwsA(isA<UntrustedCertificate>()));

      await authorities.trust(url, readCa('ca.pem'));
      expect(await ping(api), {'status': 'OK'});

      await authorities.forget(url);
      await expectLater(ping(api), throwsA(isA<UntrustedCertificate>()));
      api.close();
    });

    test('remembers the CA across restarts, only for its server', () async {
      await TrustedAuthorities(() async => store.path)
          .trust(url, readCa('ca.pem'));

      final restarted = TrustedAuthorities(() async => store.path);
      final api = apiWith(restarted);
      expect(await ping(api), {'status': 'OK'});
      api.close();

      final other = Uri.parse('https://localhost:${server.port}');
      expect(restarted.pemFor(other), null);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

/// A Secret Service keyring that is locked, or not running at all.
class _LockedKeyring extends FlutterSecureStorage {
  _LockedKeyring();

  var asked = 0;
  var locked = true;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    asked++;
    if (locked) throw PlatformException(code: 'Libsecret error');
    return 'secret';
  }
}

void main() {
  late HttpServer server;
  late List<HttpRequest> seen;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    seen = [];
    server.listen((req) async {
      seen.add(req);
      req.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'id': 'u1', 'username': 'alice'}));
      await req.response.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('a locked keyring fails requests with what to do, asking it once '
      'until the user tries again', () async {
    final keyring = _LockedKeyring();
    final tokens = TokenStore(keyring);
    const url = 'https://chat.example.com';
    final api = ServerApi(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
      token: () => tokens.read(url),
    );
    Future<Object?> request() => api
        .call(() => api.client.users.getUser(userId: 'me'))
        .then<Object?>((u) => u, onError: (Object e) => e);

    final failures = await Future.wait([request(), request(), request()]);
    expect(failures, everyElement(isA<KeyringUnavailable>()));
    expect(
      connectionProblemText(failures.first! as ApiError, 'chat.example.com'),
      keyringUnavailableText,
    );
    expect(keyring.asked, 1);
    expect(seen, isEmpty);
    expect(tokens.unavailable, isTrue);

    keyring.locked = false;
    expect(await request(), isA<KeyringUnavailable>());
    expect(keyring.asked, 1);

    tokens.retry();
    final me = await request();
    expect(me, isNot(isA<ApiError>()));
    expect(seen.single.headers.value('authorization'), 'Bearer secret');
    expect(tokens.unavailable, isFalse);
  });
}

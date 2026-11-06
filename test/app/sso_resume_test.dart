import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/sso_resume.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/pending_sso_store.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/domain/pending_sso.dart';
import 'package:matterleast/domain/sso_callback.dart';
import 'package:path/path.dart' as p;

import '../support/fake_server.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeServer server;
  late AppDatabase db;
  late TokenStore tokens;
  late Directory dir;
  late ServerManager manager;
  late PendingSsoStore store;
  late ProviderContainer container;
  final now = DateTime.utc(2026, 11, 6, 12);
  var clock = now;

  setUp(() async {
    clock = now;
    server = await FakeServer.start();
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/login/sso/code-exchange' => ok({'token': 's3ss10n'}),
      '/api/v4/users/me' =>
        r.header('authorization') == 'Bearer s3ss10n'
            ? ok(fixtureMap('me'))
            : error(401, 'api.context.session_expired.app_error'),
      _ => mattermostProbe(r) ?? error(404, 'not_found'),
    };
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStore();
    store = PendingSsoStore(tokens);
    dir = await Directory.systemTemp.createTemp('sso_resume');
    manager = ServerManager(
      db: db,
      tokens: tokens,
      dataDirectory: () async => dir.path,
      cacheDirectory: () async => p.join(dir.path, 'cache'),
      openDatabase: (path) => ServerDatabase(NativeDatabase(File(path))),
      clock: () => now,
      clearShared: () async {},
      onHidden: (_) async {},
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        serverManagerProvider.overrideWithValue(manager),
        pendingSsoStoreProvider.overrideWithValue(store),
        ssoResumeProvider.overrideWith(
          (ref) => SsoResume(ref, clock: () => clock),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await manager.dispose();
    await db.close();
    await server.close();
    await dir.delete(recursive: true);
  });

  PendingSso pending({DateTime? startedAt}) {
    final challenge = SsoChallenge.generate();
    return PendingSso(
      serverUrl: server.url.toString(),
      displayName: 'Team Chat',
      state: challenge.state,
      verifier: challenge.verifier,
      startedAt: startedAt ?? now,
    );
  }

  Uri callback() => Uri.parse(
    'mmauth://callback?login_code=one-time'
    '&srv=${Uri.encodeComponent(server.url.toString())}',
  );

  test('a callback after a restart signs in the saved server', () async {
    final saved = pending();
    await store.save(saved);

    expect(await container.read(ssoResumeProvider).resume(callback()), isTrue);

    expect(await tokens.read(server.url.toString()), 's3ss10n');
    expect(
      (await db.serverByUrl(server.url.toString()))?.displayName,
      'Team Chat',
    );
    final exchange = server.seen.singleWhere(
      (r) => r.path == '/api/v4/users/login/sso/code-exchange',
    );
    expect(exchange.body['code_verifier'], saved.verifier);
    expect(exchange.body['state'], saved.state);
    expect(await store.load(), isNull);
  });

  test('without a saved sign-in a callback does nothing', () async {
    expect(await container.read(ssoResumeProvider).resume(callback()), isFalse);
    expect(await tokens.read(server.url.toString()), isNull);
    expect(server.seen, isEmpty);
  });

  test('a sign-in that timed out is dropped, not finished', () async {
    await store.save(pending());
    clock = now.add(const Duration(minutes: 11));

    expect(await container.read(ssoResumeProvider).resume(callback()), isFalse);

    expect(await tokens.read(server.url.toString()), isNull);
    expect(await store.load(), isNull);
  });

  test('a callback counts once', () async {
    await store.save(pending());
    final resume = container.read(ssoResumeProvider);
    expect(await resume.resume(callback()), isTrue);
    expect(await resume.resume(callback()), isFalse);
  });

  test('a callback naming another server signs nothing in', () async {
    await store.save(pending());
    final planted = Uri.parse(
      'mmauth://callback?login_code=one-time&srv=https%3A%2F%2Fevil.example.test',
    );

    expect(await container.read(ssoResumeProvider).resume(planted), isFalse);

    expect(await tokens.read(server.url.toString()), isNull);
    expect(await store.load(), isNull);
  });
}

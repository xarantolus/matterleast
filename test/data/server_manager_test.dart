import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/client_config.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:path/path.dart' as p;

import '../support/fake_server.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeServer server;
  late AppDatabase db;
  late TokenStore tokens;
  late Directory dir;
  late ServerManager manager;
  late String url;
  late int sharesCleared;

  setUp(() async {
    sharesCleared = 0;
    server = await FakeServer.start();
    url = server.url.toString();
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/logout' => ok({'status': 'OK'}),
      _ => error(404, 'not_found'),
    };
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStore();
    dir = await Directory.systemTemp.createTemp('servers');
    manager = ServerManager(
      db: db,
      tokens: tokens,
      dataDirectory: () async => dir.path,
      cacheDirectory: () async => p.join(dir.path, 'cache'),
      openDatabase: (path) => ServerDatabase(NativeDatabase(File(path))),
      clock: () => DateTime.utc(2026, 10, 25, 12),
      clearShared: () async => sharesCleared++,
    );
  });

  tearDown(() async {
    await manager.dispose();
    await db.close();
    await server.close();
    await dir.delete(recursive: true);
  });

  ProbedServer probed([Uri? url, String diagnosticId = 'diag-1']) {
    final config = {
      ...fixtureMap('client_config'),
      'DiagnosticId': diagnosticId,
    };
    final license = fixtureMap('client_license');
    return ProbedServer(
      url: url ?? server.url,
      options: _loginOptions(config, license),
      config: config,
      license: license,
    );
  }

  final me = api.User.fromJson(fixtureMap('me'));

  Future<void> addServer([ProbedServer? server]) => manager.addSignedIn(
    server: server ?? probed(),
    displayName: 'Test server',
    signedIn: SignedIn(token: 's3ss10n', me: me),
  );

  List<String> dbFiles() => dir
      .listSync()
      .map((f) => p.basename(f.path))
      .where((n) => n.startsWith('server-'))
      .toList();

  test('adding a server stores its row, token and first data', () async {
    await addServer();
    final row = (await db.serverByUrl(url))!;
    expect(row.displayName, 'Test server');
    expect(row.diagnosticId, 'diag-1');
    expect(row.serverVersion, '12.0.1');
    expect(row.lastActiveAt, DateTime.utc(2026, 10, 25, 12));
    expect(await tokens.read(url), 's3ss10n');
    final session = await manager.session(url);
    final stored = await session.db.watchMe().first;
    expect(stored!.username, me.username);
    expect(dbFiles(), isNotEmpty);
  });

  test(
    'signing out tells the server and wipes everything but the row',
    () async {
      await addServer();
      expect(await manager.signOut(url), isTrue);
      final logout = server.seen.single;
      expect(logout.path, '/api/v4/users/logout');
      expect(logout.header('authorization'), 'Bearer s3ss10n');
      expect(await tokens.read(url), isNull);
      expect(dbFiles(), isEmpty);
      final row = (await db.serverByUrl(url))!;
      expect(row.lastActiveAt, isNull);
      await expectLater(manager.session(url), throwsStateError);
    },
  );

  test(
    'signing out of an unreachable server asks first, force wipes',
    () async {
      await addServer();
      server.handle = (_) => error(502, 'bad_gateway');
      expect(await manager.signOut(url), isFalse);
      expect(await tokens.read(url), 's3ss10n');
      expect((await db.serverByUrl(url))!.lastActiveAt, isNotNull);

      expect(await manager.signOut(url, force: true), isTrue);
      expect(await tokens.read(url), isNull);
      expect(dbFiles(), isEmpty);
    },
  );

  test('signing out deletes the server\'s cached images', () async {
    await addServer();
    final row = (await db.serverByUrl(url))!;
    final images = Directory(
      p.join(dir.path, 'cache', p.basenameWithoutExtension(row.dbFile)),
    );
    final avatar = File(p.join(images.path, 'identity', 'files', 'a.png'))
      ..createSync(recursive: true);
    expect(avatar.existsSync(), isTrue);

    expect(await manager.signOut(url), isTrue);
    expect(images.existsSync(), isFalse);
  });

  test('signing out deletes the copies handed to other apps', () async {
    await addServer();
    final session = await manager.session(url);
    final copy = File(p.join(session.handoffDirectory, 'f1', 'plan.pdf'))
      ..createSync(recursive: true);

    expect(await manager.signOut(url), isTrue);
    expect(copy.existsSync(), isFalse);
  });

  test('shared files are cleared once no server is signed in', () async {
    const other = 'http://other.example.test';
    await addServer();
    await addServer(probed(Uri.parse(other), 'diag-2'));

    await manager.signOut(other, force: true);
    expect(sharesCleared, 0);
    await manager.signOut(url, force: true);
    expect(sharesCleared, 1);
  });

  test('removing a server forgets it', () async {
    await addServer();
    expect(await manager.remove(url), isTrue);
    expect(await db.serverByUrl(url), isNull);
    expect(await tokens.read(url), isNull);
    expect(dbFiles(), isEmpty);
  });

  test('a 401 on a later request ends the session and wipes it', () async {
    await addServer();
    server.handle = (_) => error(401, 'api.context.session_expired.app_error');
    final ended = manager.sessionEnded.first;
    final session = await manager.session(url);
    await expectLater(
      session.api.call(() => session.api.client.users.getUser(userId: 'me')),
      throwsA(isA<ServerError>()),
    );
    final row = await ended;
    expect(row.url, url);
    expect(row.lastActiveAt, isNull);
    expect(await tokens.read(url), isNull);
    expect(dbFiles(), isEmpty);
  });

  test(
    'a session revoked while the app was closed is noticed at launch',
    () async {
      await addServer();
      server.handle = (_) =>
          error(401, 'api.context.session_expired.app_error');
      final ended = manager.sessionEnded.first;
      await manager.setForeground(true);
      expect((await ended).url, url);
      expect(await tokens.read(url), isNull);
    },
  );

  test('the same server under another address replaces the old row only when '
      'the user agreed', () async {
    const old = 'http://old.example.test';
    await addServer(probed(Uri.parse(old)));
    await manager.signOut(old, force: true);
    await expectLater(addServer(), throwsStateError);
    expect((await db.allServers()).map((r) => r.url), [old]);

    await manager.addSignedIn(
      server: probed(),
      displayName: 'Test server',
      signedIn: SignedIn(token: 's3ss10n', me: me),
      replaces: old,
    );
    expect((await db.allServers()).map((r) => r.url), [url]);
  });

  test('a signed-in server whose token is gone is signed out', () async {
    await addServer();
    await tokens.delete(url);
    await manager.checkTokens();
    expect((await db.serverByUrl(url))!.lastActiveAt, isNull);
    expect(dbFiles(), isEmpty);
  });
}

LoginOptions _loginOptions(
  Map<String, Object?> config,
  Map<String, Object?> license,
) => loginOptionsFrom(
  ClientConfig.fromJson(config),
  ClientLicense.fromJson(license),
);

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/users/user_loader.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _user(String id) => {
  'id': id,
  'username': 'name-$id',
  'first_name': 'First $id',
};

void main() {
  late FakeServer server;
  late ServerDatabase db;
  late ServerStore store;
  late ServerApi http;
  late UserLoader users;

  /// People the fake server has, by id.
  late Set<String> onServer;

  setUp(() async {
    server = await FakeServer.start();
    db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
    store = ServerStore(db);
    http = ServerApi(baseUrl: server.url, token: () => 't');
    users = UserLoader(server: http, store: store);
    onServer = {for (var i = 0; i < 300; i++) 'u$i'};
    server.handle = (r) => switch (r.path) {
      '/api/v4/users/ids' => ok([
        for (final id in (r.json! as List).cast<String>())
          if (onServer.contains(id)) _user(id),
      ]),
      '/api/v4/users/usernames' => ok([
        for (final name in (r.json! as List).cast<String>())
          if (onServer.contains(name.replaceFirst('name-', '')))
            _user(name.replaceFirst('name-', '')),
      ]),
      _ => error(404, 'not_found'),
    };
  });

  tearDown(() async {
    users.close();
    http.close();
    await db.close();
    await server.close();
  });

  Future<Set<String>> stored() async => {
    for (final u in await db.select(db.users).get()) u.id,
  };

  List<List<String>> asked(String path) => [
    for (final r in server.seen)
      if (r.path == path) (r.json! as List).cast<String>(),
  ];

  test(
    'requests close together share one call and skip stored people',
    () async {
      await store.applyUsers([api.User.fromJson(_user('u1'))]);
      await Future.wait([
        users.ensure(['u1', 'u2']),
        users.ensure(['u2', 'u3']),
        users.ensure(['']),
      ]);
      expect(asked('/api/v4/users/ids'), [
        ['u2', 'u3'],
      ]);
      expect(await stored(), {'u1', 'u2', 'u3'});

      await users.ensure(['u2', 'u3']);
      expect(asked('/api/v4/users/ids'), hasLength(1));
    },
  );

  test('people stored before roles were kept are fetched again', () async {
    await db
        .into(db.users)
        .insert(UsersCompanion.insert(id: 'u1', username: 'name-u1'));
    await store.applyUsers([api.User.fromJson(_user('u2'))]);
    await users.ensure(['u1', 'u2']);
    expect(asked('/api/v4/users/ids'), [
      ['u1'],
    ]);
    final row = await (db.select(
      db.users,
    )..where((u) => u.id.equals('u1'))).getSingle();
    expect(row.roles, isNotNull);
  });

  test('a person already on the way is not asked for again', () async {
    final handle = server.handle;
    server.handle = (r) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return handle(r);
    };
    final first = users.ensure(['u7']);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final second = users.ensure(['u7']);
    await Future.wait([first, second]);
    expect(asked('/api/v4/users/ids'), [
      ['u7'],
    ]);
  });

  test('many people are asked in chunks of 100', () async {
    await users.ensure([for (var i = 0; i < 250; i++) 'u$i']);
    expect(
      [for (final b in asked('/api/v4/users/ids')) b.length],
      [100, 100, 50],
    );
    expect((await stored()).length, 250);
  });

  test('a failure reaches every caller and the next call asks again', () async {
    final handle = server.handle;
    server.handle = (_) => error(500, 'boom');
    final calls = [
      users.ensure(['u1']),
      users.ensure(['u2']),
    ];
    for (final call in calls) {
      await expectLater(call, throwsA(isA<ServerError>()));
    }
    // Callers that don't wait for the answer just drop the failure.
    await users.ensure(['u3']).catchError((Object _) {});
    server.handle = handle;
    await users.ensure(['u1']);
    expect(await stored(), {'u1'});
  });

  test('people are found by username too', () async {
    await users.ensureUsernames(['Name-u4', 'name-u5', 'name-nobody']);
    expect(asked('/api/v4/users/usernames'), [
      ['name-u4', 'name-u5', 'name-nobody'],
    ]);
    expect(await stored(), {'u4', 'u5'});
  });

  test('a mention with trailing punctuation finds the person', () {
    expect(mentionCandidates('Name-u4.'), ['name-u4.', 'name-u4']);
    expect(mentionCandidates('pat_-'), ['pat_-', 'pat_', 'pat']);
    expect(mentionCandidates('pat'), ['pat']);
  });

  test('a mention of someone not stored is fetched by username', () async {
    final session = await testSession(server);
    addTearDown(() => closeTestSession(session));
    final links = MessageLinks(session);
    expect(await links.userIdMentioned('name-u9.'), 'u9');
    expect(asked('/api/v4/users/usernames'), [
      ['name-u9.', 'name-u9'],
    ]);
    expect(await links.userIdMentioned('name-u9'), 'u9');
    expect(asked('/api/v4/users/usernames'), hasLength(1));
    expect(await links.userIdMentioned('nobody'), isNull);
  });
}

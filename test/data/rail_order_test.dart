import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/settings_actions.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/preference_keys.dart';

import '../support/fake_server.dart';
import '../support/memory_database.dart';
import '../support/test_session.dart';

void main() {
  group('the team order', () {
    late FakeServer server;
    late ServerSession session;

    setUp(() async {
      server = await FakeServer.start();
      session = await testSession(server);
    });

    tearDown(() async {
      await closeTestSession(session);
      await server.close();
    });

    Future<String?> stored() =>
        session.db.preference(Prefs.teamsOrder.$1, Prefs.teamsOrder.$2);

    test('is saved as teams_order, comma separated, and kept', () async {
      server.handle = (_) => ok({'status': 'OK'});
      await SettingsActions(session).saveTeamsOrder(['t2', 't1', 't3']);
      final sent = server.seen.single;
      expect(sent.method, 'PUT');
      expect(sent.path, '/api/v4/users/$meId/preferences');
      final preference = (sent.json! as List).single as Map;
      expect(preference['category'], 'teams_order');
      expect(preference['value'], 't2,t1,t3');
      expect(await stored(), 't2,t1,t3');
    });

    test('goes back to the old order when the server refuses', () async {
      await session.store.applyPreferences([
        api.Preference(
          userId: meId,
          category: Prefs.teamsOrder.$1,
          name: Prefs.teamsOrder.$2,
          value: 't1,t2',
        ),
      ]);
      server.handle = (_) => error(403, 'api.context.permissions.app_error');
      await expectLater(
        SettingsActions(session).saveTeamsOrder(['t2', 't1']),
        throwsA(isA<Object>()),
      );
      expect(await stored(), 't1,t2');
    });
  });

  test('servers are shown in the order they were put in', () async {
    final db = memoryAppDatabase();
    addTearDown(db.close);
    for (final (i, name) in ['a', 'b', 'c'].indexed) {
      await db.upsertServer(
        ServersCompanion.insert(
          url: 'https://$name.example.test',
          displayName: name,
          dbFile: '$name.db',
          sortOrder: Value(i),
          addedAt: DateTime(2026),
        ),
      );
    }
    await db.setServerOrder([
      'https://c.example.test',
      'https://a.example.test',
    ]);
    expect(
      [for (final s in await db.allServers()) s.displayName],
      ['c', 'a', 'b'],
    );
  });
}

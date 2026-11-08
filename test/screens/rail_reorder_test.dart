import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/root/team_rail.dart';

import '../support/fake_server.dart';
import '../support/memory_database.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _bay = 'tm000000000000000000000t02';
const _otherServer = 'https://other.example.test/';

void main() {
  late ServerHarness h;
  late AppDatabase appDb;
  var refuse = false;

  Future<void> start(WidgetTester tester, {bool second = false}) async {
    appDb = memoryAppDatabase();
    addTearDown(appDb.close);
    h = await pumpWithServer(
      tester,
      size: const Size(500, 900),
      platform: TargetPlatform.linux,
      appDatabase: appDb,
      handle: (r) => r.method == 'PUT' && r.path.endsWith('/preferences')
          ? (refuse ? error(403, 'no_way') : ok({'status': 'OK'}))
          : emptyAnswer(r),
      seed: (session) async {
        for (final (i, url) in [
          session.url.toString(),
          if (second) _otherServer,
        ].indexed) {
          await appDb.upsertServer(
            ServersCompanion.insert(
              url: url,
              displayName: i == 0 ? 'Mine' : 'Other',
              dbFile: 'db$i',
              sortOrder: Value(i),
              addedAt: DateTime(2026),
              lastActiveAt: Value(DateTime(2026)),
            ),
          );
        }
        await session.store.applyTeams(
          [
            api.Team.fromJson({
              'id': _bay,
              'name': 'bay',
              'display_name': 'Bay',
            }),
          ],
          [
            api.TeamMember.fromJson({'team_id': _bay}),
          ],
        );
      },
      overrides: (url) => [
        serverManagerProvider.overrideWithValue(
          ServerManager(
            db: appDb,
            tokens: TokenStore(),
            dataDirectory: () async => '',
            cacheDirectory: () async => '',
          ),
        ),
        serverSessionProvider(_otherServer)
            .overrideWith((ref) => Completer<ServerSession>().future),
      ],
      home: (url) => Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final servers = [
              for (final s
                  in ref.watch(serversProvider).value ?? const <ServerEntry>[])
                if (s.signedIn) s,
            ];
            if (servers.isEmpty) return const SizedBox();
            return Row(
              children: [
                TeamRail(
                  servers: servers,
                  target: RailTarget(url: url, teamId: teamId),
                  teamId: teamId,
                ),
                const Expanded(child: SizedBox()),
              ],
            );
          },
        ),
      ),
    );
  }

  setUp(() => refuse = false);

  /// Drags in steps, as a hand does, so the list sees the move.
  Future<void> dragDown(WidgetTester tester, Finder item, double by) async {
    final gesture = await tester.startGesture(tester.getCenter(item));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(Offset(0, by / 12));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await gesture.up();
    await tester.pump();
  }

  double top(WidgetTester tester, String initial) =>
      tester.getTopLeft(find.text(initial)).dy;

  Future<String?> storedOrder() =>
      h.session.db.preference(Prefs.teamsOrder.$1, Prefs.teamsOrder.$2);

  testWidgets('dragging a team on a computer saves the new teams_order', (
    tester,
  ) async {
    await start(tester);
    expect(top(tester, 'BA'), lessThan(top(tester, 'HA')));
    await dragDown(tester, find.text('BA'), 120);
    await h.settle(
      tester,
      until: () => h.server.seen.any((r) => r.method == 'PUT'),
    );
    expect(top(tester, 'HA'), lessThan(top(tester, 'BA')));
    final sent = h.server.seen.singleWhere((r) => r.method == 'PUT');
    final preference = (sent.json! as List).single as Map;
    expect(preference['category'], 'teams_order');
    expect(preference['value'], '$teamId,$_bay');
    expect(await storedOrder(), '$teamId,$_bay');
    await h.close(tester);
  });

  testWidgets('a refused save puts the team back and says why', (tester) async {
    refuse = true;
    await start(tester);
    await dragDown(tester, find.text('BA'), 120);
    await h.settle(
      tester,
      until: () => h.server.seen.any((r) => r.method == 'PUT'),
    );
    expect(top(tester, 'BA'), lessThan(top(tester, 'HA')));
    expect(find.textContaining("Couldn't move the team."), findsOneWidget);
    expect(find.textContaining('no_way'), findsOneWidget);
    expect(await storedOrder(), anyOf(isNull, isEmpty));
    await h.close(tester);
  });

  testWidgets('another device changing the order moves the icons', (
    tester,
  ) async {
    await start(tester);
    await h.session.store.applyPreferences([
      api.Preference(
        userId: meId,
        category: Prefs.teamsOrder.$1,
        name: Prefs.teamsOrder.$2,
        value: '$teamId,$_bay',
      ),
    ]);
    await h.settle(tester);
    expect(top(tester, 'HA'), lessThan(top(tester, 'BA')));
    await h.close(tester);
  });

  testWidgets('dragging a server group on a computer saves the server order', (
    tester,
  ) async {
    await start(tester, second: true);
    final first = find.byTooltip('Drag to move this server').first;
    await dragDown(tester, first, 300);
    await h.settle(tester);
    expect(
      [for (final s in await appDb.allServers()) s.url],
      [_otherServer, h.url],
    );
    await h.close(tester);
  });
}

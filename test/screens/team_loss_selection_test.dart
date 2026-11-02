import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/root/place_reconciler.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';

/// Remembers what was picked without touching settings.
class _Rail extends RailSelection {
  _Rail(this.start);

  final RailTarget? start;

  @override
  RailTarget? build() => start;

  @override
  void select(RailTarget? target) => state = target;
}

const _url = 'https://chat.example.test';

RailTeam _team(String id) =>
    RailTeam(id: id, displayName: id, unread: false, mentions: 0);

void main() {
  late StreamController<List<RailTeam>> teams;
  late ProviderContainer container;

  Future<void> start(RailTarget? selected) async {
    teams = StreamController<List<RailTeam>>.broadcast();
    addTearDown(teams.close);
    container = ProviderContainer(
      overrides: [
        railSelectionProvider.overrideWith(() => _Rail(selected)),
        serversProvider.overrideWith(
          (ref) => Stream.value([
            ServerEntry(
              url: _url,
              displayName: 'Chat',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: DateTime(2026),
              ssoScheme: null,
            ),
          ]),
        ),
        railTeamsProvider(_url).overrideWith((ref) {
          ref.keepAlive();
          return teams.stream;
        }),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(serversProvider, (_, _) {})
      ..listen(railTeamsProvider(_url), (_, _) {})
      ..read(placeReconcilerProvider);
    teams.add([_team('a'), _team('b'), _team('c')]);
    await pumpEventQueue();
  }

  Future<void> teamsNow(List<String> ids) async {
    teams.add([for (final id in ids) _team(id)]);
    await pumpEventQueue();
  }

  RailTarget? selection() => container.read(railSelectionProvider);

  test('leaving the shown team moves the rail to the next one', () async {
    await start(const RailTarget(url: _url, teamId: 'b'));
    await teamsNow(['a', 'c']);
    expect(selection(), const RailTarget(url: _url, teamId: 'c'));
  });

  test('leaving the last team of the list moves to the one before', () async {
    await start(const RailTarget(url: _url, teamId: 'c'));
    await teamsNow(['a', 'b']);
    expect(selection(), const RailTarget(url: _url, teamId: 'b'));
  });

  test('losing every team of the server goes Home', () async {
    await start(const RailTarget(url: _url, teamId: 'a'));
    await teamsNow([]);
    expect(selection(), isNull);
  });

  test('losing another team leaves the shown one alone', () async {
    await start(const RailTarget(url: _url, teamId: 'a'));
    await teamsNow(['a', 'b']);
    expect(selection(), const RailTarget(url: _url, teamId: 'a'));
  });
}

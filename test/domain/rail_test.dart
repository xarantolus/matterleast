import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/rail.dart';

RailTeam team(String id) =>
    RailTeam(id: id, displayName: id, unread: false, mentions: 0);

void main() {
  test('the last rail item survives a restart, Home included', () {
    const target = RailTarget(url: 'https://chat.example.test', teamId: 't2');
    final setting = Settings.lastRailTarget;
    expect(setting.read({setting.key: setting.encode(target)}), target);
    expect(setting.read({setting.key: setting.encode(null)}), isNull);
    expect(setting.read({setting.key: 'not json'}), isNull);
    expect(setting.read({}), isNull);
  });

  test('a team the user left falls back to the first one', () {
    const url = 'https://chat.example.test';
    final teams = [team('a'), team('b')];
    expect(shownTeam(const RailTarget(url: url, teamId: 'b'), teams), 'b');
    expect(shownTeam(const RailTarget(url: url, teamId: 'gone'), teams), 'a');
    expect(shownTeam(const RailTarget(url: url), teams), 'a');
    expect(shownTeam(const RailTarget(url: url, teamId: 'b'), []), 'b');
    expect(shownTeam(null, teams), isNull);
  });
}

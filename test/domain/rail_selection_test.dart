import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/rail.dart';

RailTeam team(String id) =>
    RailTeam(id: id, displayName: id, unread: false, mentions: 0);

void main() {
  group('the selection when teams go away', () {
    final before = [team('a'), team('b'), team('c')];
    const url = 'https://chat.example.test';

    RailTarget? settle(
      RailTarget? selected,
      List<RailTeam>? before,
      List<String> after,
    ) => settledSelection(
      selected,
      before: before,
      after: [for (final id in after) team(id)],
    );

    test('the next team in order takes over', () {
      expect(
        settle(const RailTarget(url: url, teamId: 'b'), before, ['a', 'c']),
        const RailTarget(url: url, teamId: 'c'),
      );
    });

    test('the last team passes to the one before it', () {
      expect(
        settle(const RailTarget(url: url, teamId: 'c'), before, ['a', 'b']),
        const RailTarget(url: url, teamId: 'b'),
      );
    });

    test('no team left means Home', () {
      expect(
        settle(const RailTarget(url: url, teamId: 'b'), before, []),
        isNull,
      );
    });

    test('a team that stays, a server alone and Home stay', () {
      const kept = RailTarget(url: url, teamId: 'b');
      expect(settle(kept, before, ['a', 'b']), kept);
      const server = RailTarget(url: url);
      expect(settle(server, before, ['a']), server);
      expect(settle(null, before, ['a']), isNull);
    });

    test('before any team is known nothing moves; a missing one gives way '
        'to the first', () {
      const picked = RailTarget(url: url, teamId: 'b');
      expect(settle(picked, null, []), picked);
      expect(
        settle(picked, null, ['x', 'y']),
        const RailTarget(url: url, teamId: 'x'),
      );
    });
  });
}

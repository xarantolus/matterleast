import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/rail.dart';

const _a = 'https://a.example';
const _b = 'https://b.example';

Location _channel(
  String url,
  String id, {
  String? root,
  String? highlight,
  ReadingAt? at,
}) => Location(
  place: RailTarget(url: url, teamId: 't1'),
  conversation: SavedConversation(
    url: url,
    channelId: id,
    title: id,
    teamId: 't1',
    rootId: root,
  ),
  highlightPostId: highlight,
  at: at,
);

const _home = Location();

OpenHistory<Location> _history() =>
    OpenHistory(repeats: (entry, current) => entry.repeats(current));

bool _all(Location _) => true;

void main() {
  group('history of locations', () {
    test('Back and Forward walk the places, across servers and threads', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_b, 'y'))
        ..push(_channel(_b, 'y', root: 'p1'));
      expect(
        h.step(forward: false, exists: _all)?.conversation?.channelId,
        'y',
      );
      expect(h.current?.conversation?.rootId, isNull);
      expect(h.current?.conversation?.url, _b);
      expect(h.step(forward: false, exists: _all)?.conversation?.url, _a);
      expect(h.step(forward: false, exists: _all), isNull);
      expect(h.step(forward: true, exists: _all)?.conversation?.url, _b);
      expect(h.step(forward: true, exists: _all)?.conversation?.rootId, 'p1');
      expect(h.step(forward: true, exists: _all), isNull);
    });

    test('a new place after Back drops what was ahead', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_a, 'y'))
        ..push(_channel(_a, 'z'));
      h.step(forward: false, exists: _all);
      h.push(_channel(_a, 'w'));
      expect(h.step(forward: true, exists: _all), isNull);
      expect(h.entries.map((e) => e.conversation?.channelId), ['x', 'y', 'w']);
    });

    test('the same place twice in a row is one entry', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_a, 'x'))
        ..push(_channel(_a, 'x', at: (postId: 'p', offset: 3)));
      expect(h.entries, hasLength(1));
    });

    test('a jump to a message in the same channel is an entry of its own', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_a, 'x', highlight: 'p9'))
        ..push(_channel(_a, 'x', highlight: 'p9'));
      expect(h.entries, hasLength(2));
    });

    test('the same channel and another thread is another place', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_a, 'x', root: 'p1'))
        ..push(_channel(_a, 'x', root: 'p2'));
      expect(h.entries, hasLength(3));
    });

    test('keeps about a hundred entries', () {
      final h = _history();
      for (var i = 0; i < 130; i++) {
        h.push(_channel(_a, 'c$i'));
      }
      expect(h.entries, hasLength(100));
      expect(h.current?.conversation?.channelId, 'c129');
      expect(h.entries.first.conversation?.channelId, 'c30');
    });

    test('Back skips and forgets what is gone, silently', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_channel(_b, 'y'))
        ..push(_channel(_a, 'z'));
      final back = h.step(
        forward: false,
        exists: (e) => e.conversation?.url != _b,
      );
      expect(back?.conversation?.channelId, 'x');
      expect(h.entries, hasLength(2));
    });

    test('nothing to go to leaves the place where it is', () {
      final h = _history()..push(_channel(_a, 'x'));
      expect(h.step(forward: false, exists: _all), isNull);
      expect(h.step(forward: true, exists: _all), isNull);
      expect(h.current?.conversation?.channelId, 'x');
    });
  });

  group('settling before going somewhere', () {
    test('where the reader is becomes part of the entry they leave', () {
      final h = _history()..push(_channel(_a, 'x'));
      settleHistory(h, _channel(_a, 'x', at: (postId: 'p7', offset: 40)));
      expect(h.current?.at, (postId: 'p7', offset: 40));
    });

    test('an entry opened at a message keeps opening there', () {
      final h = _history()..push(_channel(_a, 'x', highlight: 'p9'));
      settleHistory(h, _channel(_a, 'x', at: (postId: 'p7', offset: 40)));
      expect(h.current?.at, isNull);
      expect(h.current?.highlightPostId, 'p9');
    });

    test('Home and a conversation that are not in it yet are added', () {
      final h = _history();
      settleHistory(h, _home);
      expect(h.entries, [_home]);
      settleHistory(h, _channel(_a, 'x'));
      expect(h.entries, hasLength(2));
    });

    test("a team's list alone is no entry", () {
      final h = _history();
      settleHistory(h, const Location(place: RailTarget(url: _a)));
      expect(h.entries, isEmpty);
    });
  });

  group('locations that exist', () {
    test('a server that is not signed in has none', () {
      final x = _channel(_a, 'x');
      expect(locationExists(x, signedIn: {_b}, channels: {}), isFalse);
      expect(locationExists(x, signedIn: {_a}, channels: {}), isTrue);
    });

    test('a channel the user left or lost is gone', () {
      final x = _channel(_a, 'x');
      expect(
        locationExists(
          x,
          signedIn: {_a},
          channels: {
            _a: {'y'},
          },
        ),
        isFalse,
      );
      expect(
        locationExists(
          x,
          signedIn: {_a},
          channels: {
            _a: {'x'},
          },
        ),
        isTrue,
      );
    });

    test('Home always exists', () {
      expect(locationExists(_home, signedIn: {}, channels: {}), isTrue);
    });
  });

  group('the place the rail shows', () {
    const teams = [
      RailTeam(id: 't1', displayName: 'One', unread: false, mentions: 0),
      RailTeam(id: 't2', displayName: 'Two', unread: false, mentions: 0),
    ];

    test('a server that is signed out shows Home', () {
      expect(
        shownPlace(
          const RailTarget(url: _a, teamId: 't1'),
          signedIn: {_b},
          teams: teams,
        ),
        isNull,
      );
    });

    test('a team that is gone gives way to the first', () {
      expect(
        shownPlace(
          const RailTarget(url: _a, teamId: 't9'),
          signedIn: {_a},
          teams: teams,
        ),
        const RailTarget(url: _a, teamId: 't1'),
      );
    });

    test('while servers and teams are unknown the pick stands', () {
      const pick = RailTarget(url: _a, teamId: 't9');
      expect(shownPlace(pick, signedIn: null, teams: null), pick);
    });

    test('moving between servers, teams and Home leaves things behind', () {
      const a1 = RailTarget(url: _a, teamId: 't1');
      expect(placeChanged(a1, const RailTarget(url: _b, teamId: 't1')), isTrue);
      expect(placeChanged(a1, const RailTarget(url: _a, teamId: 't2')), isTrue);
      expect(placeChanged(a1, null), isTrue);
      expect(placeChanged(null, a1), isTrue);
    });

    test('learning the team of a server is no move', () {
      const a = RailTarget(url: _a);
      expect(placeChanged(a, const RailTarget(url: _a, teamId: 't1')), isFalse);
      expect(placeChanged(null, null), isFalse);
    });
  });
}

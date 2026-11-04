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

Location _view(PlaceView view, {String url = _a}) => Location(
  place: RailTarget(url: url, teamId: 't1'),
  view: view,
);

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

  group('pages that are entries', () {
    test('Threads sits between channels; Back and Forward pass it', () {
      final h = _history()
        ..push(_channel(_a, 'x'))
        ..push(_view(PlaceView.threads));
      expect(h.step(forward: false, exists: _all), _channel(_a, 'x'));
      expect(h.step(forward: true, exists: _all)?.view, PlaceView.threads);
    });

    test('a thread opened from Threads is an entry after it', () {
      final h = _history()
        ..push(_view(PlaceView.threads))
        ..push(_channel(_a, 'x', root: 'p1'));
      expect(h.step(forward: false, exists: _all)?.view, PlaceView.threads);
    });

    test('Threads and Drafts of one team are different places', () {
      expect(
        _view(PlaceView.threads).isSameSpot(_view(PlaceView.drafts)),
        isFalse,
      );
      expect(
        _view(PlaceView.threads).repeats(_view(PlaceView.threads)),
        isTrue,
      );
    });

    test('a page over a list is an entry, a bare list is not', () {
      final h = _history();
      settleHistory(h, _view(PlaceView.agents));
      expect(h.entries, hasLength(1));
    });
  });

  group('what Back does first', () {
    final channel = _channel(_a, 'x');
    final list = Location(
      place: RailTarget(url: _b, teamId: 't1'),
    );

    for (final (name, forward, page, shown, current, move) in [
      (
        'a page that is no entry closes first',
        false,
        true,
        channel,
        channel,
        HistoryMove.closePage,
      ),
      (
        'a bare list returns to the entry',
        false,
        false,
        list,
        channel,
        HistoryMove.reopenCurrent,
      ),
      (
        'at the entry it steps',
        false,
        false,
        channel,
        channel,
        HistoryMove.step,
      ),
      (
        'the same place at another reading position steps',
        false,
        false,
        _channel(_a, 'x', at: (postId: 'p', offset: 1)),
        channel,
        HistoryMove.step,
      ),
      ('Forward always steps', true, true, list, channel, HistoryMove.step),
      ('no history yet steps', false, false, list, null, HistoryMove.step),
    ]) {
      test(name, () {
        expect(
          historyMove(
            forward: forward,
            pageOnTop: page,
            shown: shown,
            current: current,
          ),
          move,
        );
      });
    }
  });

  group('teams that exist', () {
    test('an entry for a team the server no longer has is gone', () {
      final x = _channel(_a, 'x');
      expect(
        locationExists(
          x,
          signedIn: {_a},
          channels: {},
          teams: {
            _a: {'t2'},
          },
        ),
        isFalse,
      );
      expect(
        locationExists(
          x,
          signedIn: {_a},
          channels: {},
          teams: {
            _a: {'t1'},
          },
        ),
        isTrue,
      );
      expect(locationExists(x, signedIn: {_a}, channels: {}), isTrue);
    });
  });
}

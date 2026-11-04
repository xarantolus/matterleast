import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/message_search.dart';

SearchServer _server(String url, {bool cross = true, String? home = 'h'}) =>
    (url: url, crossTeam: cross, homeTeam: home);

List<(String, String, bool)> _plan(
  List<SearchServer> servers,
  SearchScope scope, {
  String? server,
}) => [
  for (final r in searchRequests(servers, scope, server: server))
    (r.url, r.scope.teamId, r.scope.allTeams),
];

void main() {
  group('which servers and teams are searched', () {
    const all = SearchScope(teamId: '', allTeams: true);
    final a = _server('a', home: 'a1');
    final b = _server('b', home: 'b1');

    test('from Home every server, all of its teams', () {
      expect(_plan([a, b], all), [('a', 'a1', true), ('b', 'b1', true)]);
    });

    test('inside a server only that one', () {
      expect(_plan([a, b], all, server: 'a'), [('a', 'a1', true)]);
    });

    test('one team of a named server', () {
      expect(_plan([a, b], const SearchScope(teamId: 'a2'), server: 'a'), [
        ('a', 'a2', false),
      ]);
    });

    test('a server without cross-team search gets one team', () {
      final plain = _server('c', cross: false, home: 'c1');
      expect(_plan([plain], all), [('c', 'c1', false)]);
      expect(
        _plan(
          [plain],
          const SearchScope(teamId: 'c2', allTeams: true),
          server: 'c',
        ),
        [('c', 'c2', false)],
      );
    });

    test('a server with no team to search is left out', () {
      final none = _server('d', cross: false, home: null);
      expect(_plan([none, a], all), [('a', 'a1', true)]);
    });
  });

  group('merging servers newest first', () {
    DateTime t(int m) => DateTime.utc(2026, 1, 1, 0, m);

    test('interleaves by time', () {
      expect(
        mergeNewestFirst<(String, int)>([
          [('a1', 5), ('a2', 1)],
          [('b1', 3)],
        ], (e) => t(e.$2)).map((e) => e.$1),
        ['a1', 'b1', 'a2'],
      );
    });

    test('equal times keep the earlier server, then its own order', () {
      expect(
        mergeNewestFirst<(String, int)>([
          [('a1', 2), ('a2', 2)],
          [('b1', 2)],
        ], (e) => t(e.$2)).map((e) => e.$1),
        ['a1', 'a2', 'b1'],
      );
    });

    test('items without a time come last', () {
      expect(
        mergeNewestFirst<(String, int?)>([
          [('a', null)],
          [('b', 1)],
        ], (e) => e.$2 == null ? null : t(e.$2!)).map((e) => e.$1),
        ['b', 'a'],
      );
    });
  });

  group('one view of several servers', () {
    ({String name, SearchView<String> view}) src(
      String name,
      SearchView<String> view,
    ) => (name: name, view: view);
    const shown = SearchShown<String>(['x'], refreshing: false);

    test('loading while a server has nothing yet, never no results', () {
      expect(
        mergeSearch([
          src('a', const SearchEmpty()),
          src('b', const SearchLoading()),
        ]),
        isA<SearchLoading<String>>(),
      );
    });

    test('empty only when every server answered empty', () {
      expect(
        mergeSearch([
          src('a', const SearchEmpty()),
          src('b', const SearchEmpty()),
        ]),
        isA<SearchEmpty<String>>(),
      );
    });

    test('a failed server is listed beside the others results', () {
      final view = mergeSearch([
        src('a', shown),
        src('b', const SearchFailed('down')),
      ]);
      expect(
        view,
        isA<SearchShown<String>>()
            .having((s) => s.results, 'results', ['x'])
            .having((s) => s.failures, 'failures', [
              (name: 'b', cause: 'down'),
            ]),
      );
    });

    test('a late server keeps the progress bar on', () {
      final view = mergeSearch([
        src('a', shown),
        src('b', const SearchLoading()),
      ]);
      expect(
        view,
        isA<SearchShown<String>>().having(
          (s) => s.refreshing,
          'refreshing',
          isTrue,
        ),
      );
    });

    test('all failed shows the cause', () {
      expect(
        mergeSearch([src('a', const SearchFailed('down'))]),
        isA<SearchFailed<String>>(),
      );
    });
  });
}

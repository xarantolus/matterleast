import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/message_search.dart';

void main() {
  group('the server gets', () {
    const team = SearchScope(teamId: 't1');

    test('the words as typed, with straight quotes', () {
      expect(
        searchTerms('  “launch plan” notes ', team),
        '"launch plan" notes',
      );
    });

    test('one modifier per picked filter', () {
      final scope = team.copyWith(
        channelName: 'dock-ops',
        username: 'sam',
        after: DateTime(2026, 3, 9),
        before: DateTime(2026, 10, 1),
      );
      expect(
        searchTerms('crane', scope),
        'crane in:dock-ops from:sam before:2026-10-01 after:2026-03-09',
      );
    });

    test('a file type narrows file searches by extension only', () {
      final scope = team.copyWith(fileKind: FileKind.spreadsheets);
      expect(
        fileSearchTerms('rota', scope),
        'rota ext:xls ext:xlsx ext:csv ext:ods',
      );
      expect(searchTerms('rota', scope), 'rota');
      expect(fileSearchTerms('rota', team), 'rota');
    });

    test('only filters when no words were typed', () {
      expect(
        searchTerms('', team.copyWith(on: DateTime(2026, 1, 5))),
        'on:2026-01-05',
      );
      expect(searchTerms(' ', team), '');
    });
  });

  test('stored messages are searched for plain words and phrases', () {
    expect(localWords('Crane "Night Shift" -cancelled from:sam deliv*'), [
      'crane',
      'night shift',
      'deliv',
    ]);
  });

  group('results', () {
    test('show a spinner, not "no results", while nothing is known', () {
      expect(
        searchView<int>(local: null, server: null, serverLoading: true),
        isA<SearchLoading<int>>(),
      );
      expect(
        searchView<int>(local: const [], server: null, serverLoading: true),
        isA<SearchLoading<int>>(),
      );
    });

    test('show stored matches at once while the server is asked', () {
      final view = searchView<int>(
        local: const [1, 2],
        server: null,
        serverLoading: true,
      );
      expect(view, isA<SearchShown<int>>());
      view as SearchShown<int>;
      expect(view.results, [1, 2]);
      expect(view.refreshing, isTrue);
    });

    test("show the server's answer once it arrives", () {
      final view = searchView<int>(
        local: const [1],
        server: const [3, 1, 2],
        serverLoading: false,
      ) as SearchShown<int>;
      expect(view.results, [3, 1, 2]);
      expect(view.refreshing, isFalse);
    });

    test('keep the last answer while refreshing', () {
      final view = searchView<int>(
        local: const [1],
        server: const [3],
        serverLoading: true,
      ) as SearchShown<int>;
      expect(view.results, [3]);
      expect(view.refreshing, isTrue);
    });

    test('say "no results" only after both found nothing', () {
      expect(
        searchView<int>(
          local: const [],
          server: const [],
          serverLoading: false,
        ),
        isA<SearchEmpty<int>>(),
      );
    });

    test('keep stored matches with a notice when the server fails', () {
      final view = searchView<int>(
        local: const [1],
        server: null,
        serverLoading: false,
        serverError: "Couldn't reach chat.example.test.",
      ) as SearchShown<int>;
      expect(view.results, [1]);
      expect(view.notice, contains("Couldn't reach"));
    });

    test('explain the failure when nothing is stored either', () {
      final view = searchView<int>(
        local: const [],
        server: null,
        serverLoading: false,
        serverError: "Couldn't reach chat.example.test.",
      );
      expect(view, isA<SearchFailed<int>>());
    });
  });

  test('a day header goes before each day of results', () {
    final rows = withDays<DateTime>([
      DateTime(2026, 5, 2, 18),
      DateTime(2026, 5, 2, 9),
      DateTime(2026, 4, 30, 12),
    ], (t) => t);
    expect(rows, [
      DateTime(2026, 5, 2),
      DateTime(2026, 5, 2, 18),
      DateTime(2026, 5, 2, 9),
      DateTime(2026, 4, 30),
      DateTime(2026, 4, 30, 12),
    ]);
  });
}

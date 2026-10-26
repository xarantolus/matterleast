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

    test("the server's answer adds below the stored matches, which stay "
        'where they are', () {
      final view = searchView<int>(
        local: const [1],
        server: const [3, 1, 2],
        serverLoading: false,
      ) as SearchShown<int>;
      expect(view.results, [1]);
      expect(view.more, [3, 2]);
      expect(view.refreshing, isFalse);
    });

    test("without stored matches the server's answer shows as it is", () {
      final view = searchView<int>(
        local: const [],
        server: const [3, 1, 2],
        serverLoading: false,
      ) as SearchShown<int>;
      expect(view.results, [3, 1, 2]);
      expect(view.more, isEmpty);
    });

    test('the same result is recognised by its key', () {
      final view = searchView<(int, String)>(
        local: const [(1, 'saved')],
        server: const [(1, 'fresh'), (2, 'fresh')],
        serverLoading: false,
        keyOf: (r) => r.$1,
      ) as SearchShown<(int, String)>;
      expect(view.results, [(1, 'saved')]);
      expect(view.more, [(2, 'fresh')]);
    });

    test('keep the last answer while refreshing', () {
      final view = searchView<int>(
        local: const [],
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

  group(
    'the time zone of the picked day',
    skip: _berlin ? false : 'needs TZ=Europe/Berlin',
    () {
      final winter = DateTime(2026, 11, 2, 9);

      test('a summer day is read in summer time from winter', () {
        expect(
          searchTimeZoneOffset('crane on:2026-07-01', now: winter),
          const Duration(hours: 2),
        );
        expect(
          searchTimeZoneOffset(
            'crane after:2026-03-30 before:2026-12-01',
            now: winter,
          ),
          const Duration(hours: 2),
        );
      });

      test("without a day, or on a winter day, the offset is today's", () {
        expect(
          searchTimeZoneOffset('crane', now: winter),
          const Duration(hours: 1),
        );
        expect(
          searchTimeZoneOffset('crane on:2026-12-24', now: winter),
          const Duration(hours: 1),
        );
      });
    },
  );
}

/// Whether the tests run in Central European time.
final _berlin =
    DateTime(2026, 3, 28, 12).timeZoneOffset == const Duration(hours: 1) &&
    DateTime(2026, 7, 1).timeZoneOffset == const Duration(hours: 2);

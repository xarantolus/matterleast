import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';

void main() {
  final base = DateTime.utc(2026, 10, 20, 9);

  PostItem post(String id, int minute, {String user = 'bob'}) => PostItem(
    id: id,
    key: id,
    userId: user,
    authorName: user,
    createAt: base.add(Duration(minutes: minute)),
    message: id,
  );

  final posts = [for (var i = 9; i >= 0; i--) post('p$i', i * 10)];

  List<ListRow> rows({DateTime? lastViewedAt}) =>
      buildRows(posts, lastViewedAt: lastViewedAt, myUserId: 'alice');

  group('open position', () {
    test('a requested message wins and is centred', () {
      final at = openPosition(
        rows: rows(lastViewedAt: base),
        height: 800,
        now: base,
        highlightKey: 'p3',
      );
      expect(at, isA<OpenCentred>().having((o) => o.key, 'key', 'p3'));
    });

    test('unread messages open with the line a quarter from the top, '
        'anchoring the message above it', () {
      final at = openPosition(
        rows: rows(lastViewedAt: base.add(const Duration(minutes: 45))),
        height: 800,
        now: base,
      );
      expect(
        at,
        isA<OpenAtRow>()
            .having((o) => o.key, 'key', 'p4')
            .having((o) => o.offset, 'offset', 600),
      );
    });

    test('a recent saved place opens when nothing newer arrived', () {
      final saved = (
        postId: 'p5',
        offset: 120.0,
        savedAt: base.add(const Duration(hours: 2)),
      );
      final at = openPosition(
        rows: rows(),
        height: 800,
        now: base.add(const Duration(days: 2)),
        saved: saved,
      );
      expect(
        at,
        isA<OpenAtRow>()
            .having((o) => o.key, 'key', 'p5')
            .having((o) => o.offset, 'offset', 120),
      );
    });

    test('a saved place is dropped after newer messages or 30 days', () {
      final before = (postId: 'p5', offset: 120.0, savedAt: base);
      expect(
        openPosition(rows: rows(), height: 800, now: base, saved: before),
        isA<OpenAtBottom>(),
      );
      final old = (
        postId: 'p5',
        offset: 120.0,
        savedAt: base.add(const Duration(hours: 2)),
      );
      expect(
        openPosition(
          rows: rows(),
          height: 800,
          now: base.add(const Duration(days: 31)),
          saved: old,
        ),
        isA<OpenAtBottom>(),
      );
    });

    test('otherwise the bottom', () {
      expect(
        openPosition(rows: rows(), height: 800, now: base),
        isA<OpenAtBottom>(),
      );
    });
  });

  group('refresh plan', () {
    test('nothing stored: the newest page', () {
      expect(
        refreshPlan(hasRange: false, postsFetchedAt: base, newestStored: base),
        isA<FetchNewestPage>(),
      );
    });

    test('stored: changes since the last fetch, else the newest message', () {
      final fetched = base.add(const Duration(minutes: 5));
      expect(
        refreshPlan(
          hasRange: true,
          postsFetchedAt: fetched,
          newestStored: base,
        ),
        isA<FetchSince>().having((p) => p.since, 'since', fetched),
      );
      expect(
        refreshPlan(hasRange: true, postsFetchedAt: null, newestStored: base),
        isA<FetchSince>().having((p) => p.since, 'since', base),
      );
    });

    test('an empty range with no time: the newest page', () {
      expect(
        refreshPlan(hasRange: true, postsFetchedAt: null, newestStored: null),
        isA<FetchNewestPage>(),
      );
    });
  });

  group('thread read mark', () {
    test('goes to the channel team with collapsed reply threads', () {
      expect(
        threadReadTeam(
          collapsedThreads: true,
          channelTeamId: 'team-a',
          currentTeamId: 'team-b',
        ),
        'team-a',
      );
    });

    test('direct messages use the team in view', () {
      expect(
        threadReadTeam(
          collapsedThreads: true,
          channelTeamId: '',
          currentTeamId: 'team-b',
        ),
        'team-b',
      );
    });

    test('nothing without collapsed reply threads or a team', () {
      expect(
        threadReadTeam(
          collapsedThreads: false,
          channelTeamId: 'team-a',
          currentTeamId: 'team-b',
        ),
        isNull,
      );
      expect(
        threadReadTeam(
          collapsedThreads: true,
          channelTeamId: '',
          currentTeamId: null,
        ),
        isNull,
      );
    });
  });
}

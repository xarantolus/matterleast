import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/post_list.dart';

void main() {
  // Local times, so day boundaries don't depend on the machine's zone.
  final morning = DateTime(2026, 10, 20, 9);

  PostItem post(
    String id,
    DateTime at, {
    String user = 'bob',
    String type = '',
    bool deleted = false,
    DateTime? editAt,
  }) => PostItem(
    id: id,
    key: id,
    userId: user,
    authorName: user,
    createAt: at.toUtc(),
    message: 'message $id',
    type: type,
    deleted: deleted,
    editAt: editAt,
  );

  /// Newest first, as the store hands them over.
  List<ListRow> rowsOf(
    List<PostItem> oldestFirst, {
    DateTime? lastViewedAt,
    String me = 'alice',
  }) => buildRows(
    oldestFirst.reversed.toList(),
    lastViewedAt: lastViewedAt?.toUtc(),
    myUserId: me,
  );

  String describe(ListRow row) => switch (row) {
    MessageRow(:final post, :final compact) =>
      compact ? '${post.id}+' : post.id,
    DaySeparator(:final day) => 'day ${day.day}',
    NewMessagesLine(:final count) => 'new $count',
  };

  List<String> shown(List<ListRow> rows) =>
      rows.reversed.map(describe).toList();

  test('a person writing again within five minutes continues their row', () {
    final rows = rowsOf([
      post('a', morning),
      post('b', morning.add(const Duration(minutes: 4))),
      post('c', morning.add(const Duration(minutes: 10))),
      post('d', morning.add(const Duration(minutes: 11)), user: 'carol'),
    ]);
    expect(shown(rows), ['day 20', 'a', 'b+', 'c', 'd']);
  });

  test('system messages never join a row', () {
    final rows = rowsOf([
      post('a', morning),
      post(
        'join',
        morning.add(const Duration(minutes: 1)),
        type: 'system_join_channel',
      ),
      post('b', morning.add(const Duration(minutes: 2))),
    ]);
    expect(shown(rows), ['day 20', 'a', 'join', 'b']);
  });

  test('a new day gets a separator and starts a new row', () {
    final rows = rowsOf([
      post('a', DateTime(2026, 10, 20, 23, 58)),
      post('b', DateTime(2026, 10, 21, 0, 1)),
    ]);
    expect(shown(rows), ['day 20', 'a', 'day 21', 'b']);
  });

  test('the new-messages line sits before the first unseen message from '
      'someone else and counts what follows', () {
    final rows = rowsOf([
      post('seen', morning),
      post('mine', morning.add(const Duration(minutes: 2)), user: 'alice'),
      post('x', morning.add(const Duration(minutes: 3))),
      post('y', morning.add(const Duration(minutes: 4))),
    ], lastViewedAt: morning.add(const Duration(minutes: 1)));
    expect(shown(rows), ['day 20', 'seen', 'mine', 'new 2', 'x', 'y+']);
    expect(rows.first.key, 'y');
    expect(rows[2].key, newMessagesKey);
  });

  test('no line when everything was seen', () {
    final rows = rowsOf([
      post('a', morning),
    ], lastViewedAt: morning.add(const Duration(minutes: 1)));
    expect(rows.whereType<NewMessagesLine>(), isEmpty);
  });

  test('deleted and edited messages keep their rows and say so', () {
    final edited = post('e', morning, editAt: morning);
    final deleted = post('d', morning, deleted: true, editAt: morning);
    expect(edited.edited, isTrue);
    expect(deleted.edited, isFalse);
    final rows = rowsOf([edited, deleted]);
    expect(shown(rows), ['day 20', 'e', 'd+']);
  });

  test('row keys are stable and distinct per kind', () {
    final rows = rowsOf([post('a', morning)], lastViewedAt: DateTime(2026));
    expect({for (final r in rows) r.key}, {'a', 'day:2026-10-20', 'new-line'});
  });

  group('day labels', () {
    final now = DateTime(2026, 10, 25, 15);
    test('today and yesterday by name', () {
      expect(dayLabel(DateTime(2026, 10, 25), now), 'Today');
      expect(dayLabel(DateTime(2026, 10, 24), now), 'Yesterday');
    });
    test('older days with weekday, and the year when it differs', () {
      expect(dayLabel(DateTime(2026, 10, 20), now), 'Tue 20 Oct');
      expect(dayLabel(DateTime(2025, 10, 20), now), 'Mon 20 Oct 2025');
    });
    test('yesterday across a month boundary', () {
      expect(
        dayLabel(DateTime(2026, 10, 31), DateTime(2026, 11, 1)),
        'Yesterday',
      );
    });
  });
}

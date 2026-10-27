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

  test('joins after the last visit and live messages draw no line', () {
    final opened = morning.add(const Duration(minutes: 5));
    final rows = buildRows(
      [
        post('live', opened.add(const Duration(minutes: 1))),
        post(
          'joined',
          morning.add(const Duration(minutes: 3)),
          type: 'system_join_channel',
        ),
        post('seen', morning),
      ],
      lastViewedAt: morning.add(const Duration(minutes: 1)).toUtc(),
      myUserId: 'alice',
      unreadUntil: opened.toUtc(),
    );
    expect(rows.whereType<NewMessagesLine>(), isEmpty);
  });

  test('unchanged rows stay the same objects across updates', () {
    final before = rowsOf([post('a', morning), post('b', morning)]);
    final after = reuseRows(
      before,
      rowsOf([post('a', morning), post('b', morning, editAt: morning)]),
    );
    final a = before.firstWhere((r) => r.key == 'a');
    final b = before.firstWhere((r) => r.key == 'b');
    expect(after.any((r) => identical(r, a)), isTrue);
    expect(after.any((r) => identical(r, b)), isFalse);
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

  test('unreads can be summarised only while the new-messages line shows', () {
    final seen = morning.add(const Duration(minutes: 1)).toUtc();
    final unread = rowsOf([
      post('a', morning),
      post('b', morning.add(const Duration(minutes: 2))),
    ], lastViewedAt: seen);
    final read = rowsOf([post('a', morning)], lastViewedAt: seen);
    expect(unreadSince(unread, seen), seen);
    expect(unreadSince(read, seen), isNull);
  });
}

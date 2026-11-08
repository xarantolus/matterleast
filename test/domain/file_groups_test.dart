import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/time_labels.dart';

void main() {
  final now = DateTime(2026, 10, 28, 15);
  List<String> labels(List<DateTime?> times, {DateTime? at}) => [
    for (final g in groupFiles<DateTime?>(
      times,
      timeOf: (t) => t,
      isMedia: (_) => false,
      now: at ?? now,
    ))
      g.label(at ?? now),
  ];

  group('groupFiles', () {
    test('a day each within the past week, then one group per month', () {
      expect(
        labels([
          DateTime(2026, 10, 28, 9),
          DateTime(2026, 10, 28, 8),
          DateTime(2026, 10, 27, 23, 59),
          DateTime(2026, 10, 24),
          DateTime(2026, 10, 21),
          DateTime(2026, 10, 2),
          DateTime(2026, 9, 30),
          DateTime(2025, 12, 31),
        ]),
        [
          'Today',
          'Yesterday',
          'Saturday',
          'October',
          'September',
          'December 2025',
        ],
      );
    });

    test('midnight decides the day, not 24 hours', () {
      expect(
        labels([DateTime(2026, 10, 28, 0, 1), DateTime(2026, 10, 27, 23, 59)]),
        ['Today', 'Yesterday'],
      );
    });

    test('the year boundary', () {
      final jan = DateTime(2027, 1, 2, 10);
      expect(labels([DateTime(2027, 1, 1), DateTime(2026, 12, 31)], at: jan), [
        'Yesterday',
        'Thursday',
      ]);
      expect(labels([DateTime(2026, 12, 20)], at: jan), ['December 2026']);
    });

    test('a clock change does not shift the day', () {
      // Local dates, so a 23 or 25 hour day is still one day.
      final after = DateTime(2026, 3, 30, 12);
      expect(labels([DateTime(2026, 3, 29, 12)], at: after), ['Yesterday']);
      expect(labels([DateTime(2026, 3, 28, 12)], at: after), ['Saturday']);
    });

    test('pictures and videos form the grid, others follow', () {
      final g = groupFiles<(String, bool)>(
        [('a.png', true), ('b.pdf', false), ('c.mp4', true)],
        timeOf: (_) => DateTime(2026, 10, 28),
        isMedia: (f) => f.$2,
        now: now,
      ).single;
      expect(g.media.map((f) => f.$1), ['a.png', 'c.mp4']);
      expect(g.others.map((f) => f.$1), ['b.pdf']);
    });

    test('a file without a time joins the last group', () {
      final groups = groupFiles<DateTime?>(
        [DateTime(2026, 10, 28), null],
        timeOf: (t) => t,
        isMedia: (_) => false,
        now: now,
      );
      expect(groups, hasLength(1));
      expect(groups.single.others, hasLength(2));
    });
  });

  test('monthLabel names the year only when it is not this one', () {
    expect(monthLabel(DateTime(2026, 2, 3), now), 'February');
    expect(monthLabel(DateTime(2025, 2, 3), now), 'February 2025');
  });

  test('mediaColumns grows with the width and never drops below three', () {
    expect(mediaColumns(200), 3);
    expect(mediaColumns(360), 3);
    expect(mediaColumns(520), 4);
    expect(mediaColumns(1600), 12);
    expect(mediaColumns(5000), 12);
  });

  test('fileTypeLabel is the extension in capitals, at most four letters', () {
    expect(fileTypeLabel('pdf'), 'PDF');
    expect(fileTypeLabel('docx'), 'DOCX');
    expect(fileTypeLabel('torrent'), 'TORR');
    expect(fileTypeLabel(''), 'FILE');
  });

  group('filePageAfter', () {
    FileHit hit(String id) => FileHit(
      id: id,
      name: '$id.pdf',
      extension: 'pdf',
      mimeType: 'application/pdf',
      size: 1,
      postId: 'p',
      channelId: 'c',
      place: '',
    );
    List<FileHit> page(Iterable<String> ids) => [for (final i in ids) hit(i)];

    test('a full page of new files may be followed by another', () {
      final r = filePageAfter({}, page(['a', 'b']), size: 2);
      expect(r.fresh.map((f) => f.id), ['a', 'b']);
      expect(r.more, isTrue);
    });

    test('a short page is the last', () {
      expect(filePageAfter({}, page(['a']), size: 2).more, isFalse);
      expect(filePageAfter({}, const [], size: 2).more, isFalse);
    });

    test('files already shown are left out, and a page of nothing new stops '
        'the paging', () {
      final r = filePageAfter({'a'}, page(['a', 'b']), size: 2);
      expect(r.fresh.map((f) => f.id), ['b']);
      expect(r.more, isTrue);
      final again = filePageAfter({'a', 'b'}, page(['a', 'b']), size: 2);
      expect(again.fresh, isEmpty);
      expect(again.more, isFalse);
    });
  });
}

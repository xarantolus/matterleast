import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/post_ranges.dart';

DateTime t(int minutes) =>
    DateTime.fromMillisecondsSinceEpoch(minutes * 60000, isUtc: true);

PostRange r(int from, int to, {bool start = false}) =>
    PostRange(earliest: t(from), latest: t(to), reachesStart: start);

void main() {
  group('first page', () {
    test('creates one range that reaches the start when short', () {
      final ranges = withPage(
        [],
        earliest: t(10),
        latest: t(50),
        reachesStart: true,
      );
      expect(ranges, [r(10, 50, start: true)]);
    });

    test('an empty channel is recorded, not left unknown', () {
      final ranges = withPage(
        [],
        earliest: null,
        latest: null,
        reachesStart: true,
      );
      expect(ranges, [PostRange.empty]);
      expect(newestRange(ranges), PostRange.empty);
    });

    test('a later page overlapping an old range fuses with it', () {
      final ranges = withPage(
        [r(10, 50)],
        earliest: t(40),
        latest: t(90),
        reachesStart: false,
      );
      expect(ranges, [r(10, 90)]);
    });

    test('a page far from the cached range stays a separate range', () {
      final ranges = withPage(
        [r(10, 50)],
        earliest: t(200),
        latest: t(260),
        reachesStart: false,
      );
      expect(ranges, [r(10, 50), r(200, 260)]);
      expect(newestRange(ranges), r(200, 260));
    });
  });

  group('older history', () {
    test('grows the anchored range down and fuses across a gap', () {
      final ranges = withOlder(
        [r(10, 50), r(200, 260)],
        anchor: t(200),
        earliest: t(30),
        reachesStart: false,
      );
      expect(ranges, [r(10, 260)]);
    });

    test('an empty answer marks the start without moving anything', () {
      final ranges = withOlder(
        [r(10, 50)],
        anchor: t(10),
        earliest: null,
        reachesStart: true,
      );
      expect(ranges, [r(10, 50, start: true)]);
    });

    test('an anchor outside every range changes nothing', () {
      expect(
        withOlder(
          [r(10, 50)],
          anchor: t(99),
          earliest: t(5),
          reachesStart: false,
        ),
        [r(10, 50)],
      );
    });
  });

  group('newer posts', () {
    test('a since refresh raises the newest range', () {
      expect(withNewer([r(10, 50)], anchor: t(50), latest: t(70)), [r(10, 70)]);
    });

    test('edits older than the range do not shrink or move it', () {
      expect(withNewer([r(10, 50)], anchor: t(50), latest: t(40)), [r(10, 50)]);
    });

    test('a live post extends the newest range only', () {
      expect(withLivePost([r(10, 50), r(200, 260)], t(261)), [
        r(10, 50),
        r(200, 261),
      ]);
    });

    test('a live post in an empty channel starts its history', () {
      expect(withLivePost([PostRange.empty], t(5)), [r(5, 5, start: true)]);
    });

    test('a live post in a channel never loaded leaves it unloaded', () {
      expect(withLivePost([], t(5)), isEmpty);
    });

    test('a late post inside the range is already covered', () {
      expect(withLivePost([r(10, 50)], t(30)), [r(10, 50)]);
    });
  });

  group('pruning', () {
    test('cuts ranges at the kept boundary and drops older ones', () {
      expect(withPruned([r(10, 50, start: true), r(200, 260)], t(220)), [
        r(220, 260),
      ]);
      expect(withPruned([r(10, 50, start: true), r(200, 260)], t(40)), [
        r(40, 50),
        r(200, 260),
      ]);
    });
  });

  test('ranges are value objects', () {
    expect(r(1, 2), r(1, 2));
    expect(rangeContaining([r(1, 2), r(5, 9)], t(7)), r(5, 9));
    expect(rangeContaining([r(1, 2)], t(3)), isNull);
  });
}

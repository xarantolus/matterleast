import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/sync/draft_push_scheduler.dart';
import 'package:matterleast/domain/draft_sync.dart';

void main() {
  final t0 = DateTime.utc(2026, 3, 1, 9);

  group('shouldPushDraft', () {
    for (final (name, secondsAgo, leaving, expected) in [
      ('just typed', 0, false, false),
      ('quiet for 29 s', 29, false, false),
      ('quiet for 30 s', 30, false, true),
      ('quiet for a minute', 60, false, true),
      ('leaving right after typing', 0, true, true),
    ]) {
      test(name, () {
        expect(
          shouldPushDraft(
            lastChangeAt: t0,
            now: t0.add(Duration(seconds: secondsAgo)),
            leaving: leaving,
          ),
          expected,
        );
      });
    }
  });

  group('DraftPushScheduler', () {
    const key = (channelId: 'c1', rootId: '');
    late List<DraftKey> pushed;

    DraftPushScheduler scheduler(FakeAsync async) {
      pushed = [];
      final started = async.getClock(t0);
      return DraftPushScheduler(clock: () => started.now(), push: pushed.add);
    }

    test('typing does not push before 30 s, and does at 30 s', () {
      fakeAsync((async) {
        final s = scheduler(async)..changed(key);
        async.elapse(const Duration(seconds: 29));
        expect(pushed, isEmpty);
        async.elapse(const Duration(seconds: 1));
        expect(pushed, [key]);
        s.dispose();
      });
    });

    test('every change restarts the wait', () {
      fakeAsync((async) {
        final s = scheduler(async)..changed(key);
        async.elapse(const Duration(seconds: 20));
        s.changed(key);
        async.elapse(const Duration(seconds: 20));
        expect(pushed, isEmpty);
        async.elapse(const Duration(seconds: 10));
        expect(pushed, [key]);
        s.dispose();
      });
    });

    test('leaving pushes at once, and only once', () {
      fakeAsync((async) {
        final s = scheduler(async)..changed(key);
        async.elapse(const Duration(seconds: 2));
        s.flush(key);
        expect(pushed, [key]);
        async.elapse(const Duration(minutes: 1));
        expect(pushed, [key]);
        s.dispose();
      });
    });

    test('leaving a draft nobody typed in pushes nothing', () {
      fakeAsync((async) {
        final s = scheduler(async)..flush(key);
        expect(pushed, isEmpty);
        s.dispose();
      });
    });

    test('disposing drops the waiting pushes', () {
      fakeAsync((async) {
        final s = scheduler(async)
          ..changed(key)
          ..dispose();
        async.elapse(const Duration(minutes: 1));
        expect(pushed, isEmpty);
        s.flushAll();
        expect(pushed, isEmpty);
      });
    });
  });
}

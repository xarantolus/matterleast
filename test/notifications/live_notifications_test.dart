import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/notifications/live_notifications.dart';

void main() {
  group('history', historyTests);
  late StreamController<ServerEvent> applied;
  late StreamController<void> caughtUp;
  late int checks;
  late LiveNotifications live;

  setUp(() {
    applied = StreamController<ServerEvent>.broadcast(sync: true);
    caughtUp = StreamController<void>.broadcast(sync: true);
    checks = 0;
    live = LiveNotifications(
      applied: applied.stream,
      caughtUp: caughtUp.stream,
      check: ({required afterGap}) async => checks++,
    );
  });

  tearDown(() async {
    await applied.close();
    await caughtUp.close();
  });

  const posted = PostedEvent();

  test('a new post is checked once, two seconds after a burst ends', () {
    fakeAsync((time) {
      live.start();
      applied
        ..add(posted)
        ..add(posted);
      time.elapse(const Duration(seconds: 1));
      applied.add(posted);
      time.elapse(const Duration(milliseconds: 1999));
      expect(checks, 0);
      time.elapse(const Duration(milliseconds: 1));
      expect(checks, 1);
    });
  });

  test('catching up after a gap is checked too', () {
    fakeAsync((time) {
      live.start();
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 2));
      expect(checks, 1);
    });
  });

  test('other events are not checked', () {
    fakeAsync((time) {
      live.start();
      applied.add(const PostDeletedEvent());
      time.elapse(const Duration(seconds: 5));
      expect(checks, 0);
    });
  });

  test('nothing is checked once stopped, not even a pending check', () {
    fakeAsync((time) {
      live.start();
      applied.add(posted);
      unawaited(live.stop());
      time.elapse(const Duration(seconds: 5));
      applied.add(posted);
      time.elapse(const Duration(seconds: 5));
      expect(checks, 0);
    });
  });
}

class _Run {
  _Run(StreamController<ServerEvent> applied, StreamController<void> caughtUp) {
    live = LiveNotifications(
      applied: applied.stream,
      caughtUp: caughtUp.stream,
      history: (liveFrom) async => marks.add(liveFrom),
      check: ({required afterGap}) async => checks.add(afterGap),
    );
  }

  late final LiveNotifications live;
  final marks = <DateTime?>[];
  final checks = <bool>[];
}

void historyTests() {
  late StreamController<ServerEvent> applied;
  late StreamController<void> caughtUp;

  setUp(() {
    applied = StreamController<ServerEvent>.broadcast(sync: true);
    caughtUp = StreamController<void>.broadcast(sync: true);
  });

  tearDown(() async {
    await applied.close();
    await caughtUp.close();
  });

  final at = DateTime.utc(2026, 11, 1, 10);
  final live = PostedEvent(post: api.Post(createAt: at));

  test('the first catch-up is history: marked seen, nothing checked', () {
    fakeAsync((time) {
      final r = _Run(applied, caughtUp)..live.start();
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      expect(r.marks, [null]);
      expect(r.checks, isEmpty);
    });
  });

  test('a post that arrived before the first catch-up ended still counts', () {
    fakeAsync((time) {
      final r = _Run(applied, caughtUp)..live.start();
      applied.add(live);
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      expect(r.marks, [at]);
      expect(r.checks, [true]);
    });
  });

  test('a later catch-up after a gap checks, and a post after the first one '
      'checks', () {
    fakeAsync((time) {
      final r = _Run(applied, caughtUp)..live.start();
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      applied.add(live);
      time.elapse(const Duration(seconds: 5));
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      expect(r.marks, [null]);
      expect(r.checks, [false, true]);
    });
  });

  test('after rearming, the next catch-up is history again', () {
    fakeAsync((time) {
      final r = _Run(applied, caughtUp)..live.start();
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      r.live.rearm();
      caughtUp.add(null);
      time.elapse(const Duration(seconds: 5));
      expect(r.marks, [null, null]);
      expect(r.checks, isEmpty);
    });
  });
}

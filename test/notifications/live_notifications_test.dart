import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/notifications/live_notifications.dart';

void main() {
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
      check: () async => checks++,
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

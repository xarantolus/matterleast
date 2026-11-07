import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

/// Pumps until the app has nothing left to do, once [until] holds.
///
/// The fake servers and the databases answer on the real clock and the
/// widgets' timers run on the fake one, so each round gives both a turn
/// (20 ms real, 100 ms fake). The app is idle when no request has reached any
/// of [servers] for [quietRounds] rounds and no frame is scheduled; a frame
/// that stays scheduled for [animationRounds] quiet rounds is an animation
/// that never ends (a spinner, a video), not work. A request a server holds
/// back on purpose does not count. Pass [until] for what a timer the harness
/// cannot see (a menu closing, a debounce) leads to, such as a request the
/// server must receive. Fails after [maxRounds] rounds, saying what it waited
/// for.
Future<void> settleApp(
  WidgetTester tester, {
  Iterable<FakeServer> servers = const [],
  bool Function()? until,
  int quietRounds = 3,
  int animationRounds = 12,
  int maxRounds = 150,
}) async {
  int seen() => servers.fold(0, (sum, s) => sum + s.seen.length);
  var quiet = 0;
  var requests = seen();
  for (var round = 0; round < maxRounds; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final now = seen();
    quiet = now == requests ? quiet + 1 : 0;
    requests = now;
    if (until != null && !until()) continue;
    final animating = tester.binding.hasScheduledFrame;
    if (quiet >= (animating ? animationRounds : quietRounds)) return;
  }
  fail(
    until != null && !until()
        ? 'the awaited condition did not hold after $maxRounds rounds'
        : 'requests kept arriving for $maxRounds rounds',
  );
}

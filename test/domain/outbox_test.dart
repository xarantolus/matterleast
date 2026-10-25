import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/outbox.dart';

void main() {
  final t0 = DateTime.utc(2026, 10, 25, 10);

  OutboxEntry entry(
    String id,
    String channel, {
    int queuedSec = 0,
    String state = OutboxStates.queued,
    int? nextSec,
  }) => (
    pendingPostId: id,
    channelId: channel,
    queuedAt: t0.add(Duration(seconds: queuedSec)),
    state: state,
    nextAttemptAt: nextSec == null ? null : t0.add(Duration(seconds: nextSec)),
  );

  group('next post to send', () {
    test('the oldest post of a channel goes first', () {
      final step = nextOutboxStep([
        entry('b', 'c1', queuedSec: 2),
        entry('a', 'c1', queuedSec: 1),
      ], t0);
      expect((step as SendNow).pendingPostId, 'a');
    });

    test('a channel waiting out a backoff holds back its later posts only', () {
      final step = nextOutboxStep([
        entry('a', 'c1', queuedSec: 1, nextSec: 30),
        entry('b', 'c1', queuedSec: 2),
        entry('c', 'c2', queuedSec: 3),
      ], t0);
      expect((step as SendNow).pendingPostId, 'c');
    });

    test('failed posts are out of the line', () {
      final step = nextOutboxStep([
        entry('a', 'c1', queuedSec: 1, state: OutboxStates.failed),
        entry('b', 'c1', queuedSec: 2),
      ], t0);
      expect((step as SendNow).pendingPostId, 'b');
    });

    test('with everything backing off, wake at the earliest retry', () {
      final step = nextOutboxStep([
        entry('a', 'c1', nextSec: 30),
        entry('b', 'c2', nextSec: 8),
      ], t0);
      expect((step as WaitUntil).at, t0.add(const Duration(seconds: 8)));
    });

    test('nothing queued is idle', () {
      expect(nextOutboxStep(const [], t0), isA<OutboxIdle>());
    });
  });

  test('retries back off from 2 s, doubling up to a minute', () {
    expect(
      [for (var n = 1; n <= 7; n++) retryDelay(n).inSeconds],
      [2, 4, 8, 16, 32, 60, 60],
    );
  });

  group('after a failed send', () {
    test('no connection or server trouble is retried', () {
      for (final e in [
        const Unreachable(),
        const RequestTimeout(),
        const ServerError(statusCode: 503),
        const ServerError(statusCode: 429),
      ]) {
        expect(classifySendError(e, 1), isA<RetryLater>(), reason: '$e');
      }
    });

    test('the tenth failure gives up', () {
      expect(classifySendError(const Unreachable(), 9), isA<RetryLater>());
      expect(classifySendError(const Unreachable(), 10), isA<GiveUp>());
    });

    test('a refusal fails at once with the server message', () {
      final outcome = classifySendError(
        const ServerError(statusCode: 403, message: 'Not allowed here'),
        1,
      );
      expect((outcome as GiveUp).message, 'Not allowed here');
    });

    test('a deleted thread or a read-only channel drops the post', () {
      expect(
        classifySendError(
          const ServerError(
            statusCode: 400,
            id: 'api.post.create_post.town_square_read_only',
          ),
          1,
        ),
        isA<DropPost>(),
      );
    });
  });
}

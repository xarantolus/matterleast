import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

import '../support/fake_server.dart';

void main() {
  test('higher priority runs first and parallelism is bounded', () async {
    final runner = SyncRunner(maxParallel: 1);
    final order = <String>[];
    final gate = Completer<void>();
    unawaited(
      runner.enqueue(
        SyncJob(
          key: 'first',
          priority: SyncPriority.p2,
          run: () async {
            order.add('first');
            await gate.future;
          },
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final low = runner.enqueue(
      SyncJob(
        key: 'low',
        priority: SyncPriority.p3,
        run: () async => order.add('low'),
      ),
    );
    final urgent = runner.enqueue(
      SyncJob(
        key: 'urgent',
        priority: SyncPriority.p0,
        run: () async => order.add('urgent'),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(runner.status.value, isA<SyncRefreshing>());
    gate.complete();
    await Future.wait([low, urgent]);
    expect(order, ['first', 'urgent', 'low']);
    expect(runner.status.value, isA<SyncIdle>());
    runner.close();
  });

  test('the same key enqueued twice runs once', () async {
    final runner = SyncRunner();
    var runs = 0;
    final gate = Completer<void>();
    final a = runner.enqueue(
      SyncJob(
        key: 'k',
        run: () async {
          runs++;
          await gate.future;
        },
      ),
    );
    final b = runner.enqueue(SyncJob(key: 'k', run: () async => runs++));
    gate.complete();
    await Future.wait([a, b]);
    expect(runs, 1);
    runner.close();
  });

  test('a failure shows up in the status until the next success', () async {
    final runner = SyncRunner(clock: () => DateTime.utc(2026, 1, 1));
    await expectLater(
      runner.enqueue(
        SyncJob(key: 'bad', run: () async => throw const Unreachable()),
      ),
      throwsA(isA<Unreachable>()),
    );
    final failed = runner.status.value;
    expect(failed, isA<SyncFailed>());
    expect((failed as SyncFailed).offline, isTrue);
    await runner.enqueue(SyncJob(key: 'good', run: () async {}));
    expect(runner.status.value, isA<SyncIdle>());
    expect((runner.status.value as SyncIdle).lastSuccess, DateTime.utc(2026));
    runner.close();
  });

  test('an answer that fails to decode is not reported as offline', () async {
    final runner = SyncRunner();
    await expectLater(
      runner.enqueue(
        SyncJob(key: 'decode', run: () async => throw TypeError()),
      ),
      throwsA(isA<UnexpectedFailure>()),
    );
    final failed = runner.status.value as SyncFailed;
    expect(failed.offline, isFalse);
    runner.close();
  });

  test('a job that overruns its timeout fails as a timeout', () async {
    final runner = SyncRunner();
    await expectLater(
      runner.enqueue(
        SyncJob(
          key: 'slow',
          timeout: const Duration(milliseconds: 20),
          run: () => Future<void>.delayed(const Duration(seconds: 5)),
        ),
      ),
      throwsA(isA<RequestTimeout>()),
    );
    runner.close();
  });

  test(
    'a timed-out job stops its requests and frees its key at once',
    () async {
      final server = await FakeServer.start();
      server.handle = (_) => null;
      final api = ServerApi(baseUrl: server.url, token: () => 't');
      final runner = SyncRunner();
      var runs = 0;
      SyncJob job() => SyncJob(
        key: 'hangs',
        timeout: const Duration(milliseconds: 200),
        run: () async {
          runs++;
          await api.call(() => api.client.users.getUser(userId: 'me'));
        },
      );
      final watch = Stopwatch()..start();
      await expectLater(runner.enqueue(job()), throwsA(isA<RequestTimeout>()));
      expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
      await expectLater(runner.enqueue(job()), throwsA(isA<RequestTimeout>()));
      expect(runs, 2);
      runner.close();
      api.close();
      await server.close();
    },
  );

  test('cancelling an owner drops its queued work only', () async {
    final runner = SyncRunner(maxParallel: 1);
    final gate = Completer<void>();
    final screen = Object();
    final ran = <String>[];
    unawaited(runner.enqueue(SyncJob(key: 'busy', run: () => gate.future)));
    final mine = runner.enqueue(
      SyncJob(key: 'mine', owner: screen, run: () async => ran.add('mine')),
    );
    final other = runner.enqueue(
      SyncJob(key: 'other', run: () async => ran.add('other')),
    );
    runner.cancelOwner(screen);
    await mine;
    gate.complete();
    await other;
    expect(ran, ['other']);
    runner.close();
  });

  test('quiet jobs neither show as refreshing nor report failure', () async {
    final runner = SyncRunner();
    final gate = Completer<void>();
    final quiet = runner.enqueue(
      SyncJob(key: 'presence', visible: false, run: () => gate.future),
    );
    await Future<void>.delayed(Duration.zero);
    expect(runner.status.value, isA<SyncIdle>());
    gate.completeError(const Unreachable());
    await expectLater(quiet, throwsA(isA<Unreachable>()));
    expect(runner.status.value, isA<SyncIdle>());
    runner.close();
  });
}

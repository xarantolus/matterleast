import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/sync/sync_runner.dart';

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
}

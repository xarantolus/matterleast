import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/log.dart';

/// Lower runs first. P0 is what the user is looking at, P3 is housekeeping.
enum SyncPriority { p0, p1, p2, p3 }

/// What the runner is doing, for the slim progress bar and the status page.
@immutable
sealed class SyncStatus {
  const SyncStatus();
}

final class SyncIdle extends SyncStatus {
  const SyncIdle({this.lastSuccess});
  final DateTime? lastSuccess;
}

final class SyncRefreshing extends SyncStatus {
  const SyncRefreshing({required this.running, required this.queued});
  final int running;
  final int queued;
}

final class SyncFailed extends SyncStatus {
  const SyncFailed({required this.cause, required this.at, this.lastSuccess});
  final ApiError cause;
  final DateTime at;
  final DateTime? lastSuccess;

  bool get offline => cause is Unreachable || cause is RequestTimeout;
}

class SyncJob {
  const SyncJob({
    required this.key,
    required this.run,
    this.priority = SyncPriority.p1,
    this.timeout = const Duration(seconds: 30),
    this.owner,
    this.visible = true,
  });

  /// Jobs with the same key coalesce: a second enqueue while one is queued
  /// or running shares its outcome.
  final String key;
  final Future<void> Function() run;
  final SyncPriority priority;
  final Duration timeout;

  /// Screen or feature that wants the result; [SyncRunner.cancelOwner] drops
  /// its queued jobs when the screen goes away.
  final Object? owner;

  /// Shows as refreshing and reports failures in [SyncRunner.status]; off
  /// for small periodic work such as presence, so the progress bar doesn't
  /// blink every minute.
  final bool visible;
}

class _Queued {
  _Queued(this.job, this.sequence) : completer = Completer<void>();
  final SyncJob job;
  final int sequence;
  final Completer<void> completer;
}

/// Runs sync work by priority with bounded parallelism. Foreground and
/// background triggers enqueue here; nothing else fetches on its own.
class SyncRunner {
  SyncRunner({this.maxParallel = 2, DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final int maxParallel;
  final DateTime Function() _clock;
  final _status = ValueNotifier<SyncStatus>(const SyncIdle());
  final _queue = <_Queued>[];
  final _running = HashMap<String, _Queued>();
  final _queuedByKey = HashMap<String, _Queued>();
  var _sequence = 0;
  DateTime? _lastSuccess;
  var _closed = false;

  ValueListenable<SyncStatus> get status => _status;

  bool get isBusy => _running.isNotEmpty || _queue.isNotEmpty;

  /// Returns when the job (or the one it coalesced with) has finished.
  /// Failures are reported through [status] and rethrown to the caller.
  Future<void> enqueue(SyncJob job) {
    if (_closed) return Future.value();
    final existing = _running[job.key] ?? _queuedByKey[job.key];
    if (existing != null) return existing.completer.future;
    final queued = _Queued(job, _sequence++);
    _queue.add(queued);
    _queuedByKey[job.key] = queued;
    _publish();
    scheduleMicrotask(_pump);
    return queued.completer.future;
  }

  /// Drops queued jobs of [owner]; running ones finish on their own.
  void cancelOwner(Object owner) {
    final dropped = _queue.where((q) => q.job.owner == owner).toList();
    for (final q in dropped) {
      _queue.remove(q);
      _queuedByKey.remove(q.job.key);
      q.completer.complete();
    }
    if (dropped.isNotEmpty) _publish();
  }

  void close() {
    _closed = true;
    for (final q in _queue) {
      q.completer.complete();
    }
    _queue.clear();
    _queuedByKey.clear();
    _status.dispose();
  }

  void _pump() {
    while (!_closed && _running.length < maxParallel && _queue.isNotEmpty) {
      _queue.sort(
        (a, b) => a.job.priority.index != b.job.priority.index
            ? a.job.priority.index.compareTo(b.job.priority.index)
            : a.sequence.compareTo(b.sequence),
      );
      final next = _queue.removeAt(0);
      _queuedByKey.remove(next.job.key);
      _running[next.job.key] = next;
      _publish();
      unawaited(_execute(next));
    }
  }

  Future<void> _execute(_Queued queued) async {
    final job = queued.job;
    try {
      await job.run().timeout(
        job.timeout,
        onTimeout: () => throw const RequestTimeout(),
      );
      if (job.visible) {
        _lastSuccess = _clock();
        _failed = null;
      }
      queued.completer.complete();
    } on Object catch (error, stack) {
      final cause = error is ApiError
          ? error
          : Unreachable(detail: error.toString());
      Log.warn('sync', 'job ${job.key} failed', error);
      if (error is! ApiError) Log.warn('sync', stack.toString());
      queued.completer.completeError(cause, stack);
      if (job.visible) _failed = cause;
    } finally {
      _running.remove(job.key);
      _publish();
      _pump();
    }
  }

  ApiError? _failed;

  void _publish() {
    if (_closed) return;
    final running = _running.values.where((q) => q.job.visible).length;
    final queued = _queue.where((q) => q.job.visible).length;
    if (running + queued > 0) {
      _status.value = SyncRefreshing(running: running, queued: queued);
    } else if (_failed case final cause?) {
      _status.value = SyncFailed(
        cause: cause,
        at: _clock(),
        lastSuccess: _lastSuccess,
      );
    } else {
      _status.value = SyncIdle(lastSuccess: _lastSuccess);
    }
  }
}

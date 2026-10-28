import 'dart:async';

import 'package:matterleast/domain/draft_sync.dart';

/// Holds back the server push of drafts the user is typing: one timer per
/// draft, restarted by every change, and [flush] to push at once.
class DraftPushScheduler {
  DraftPushScheduler({required this.clock, required this.push});

  final DateTime Function() clock;
  final void Function(DraftKey key) push;

  final _timers = <DraftKey, Timer>{};
  final _changedAt = <DraftKey, DateTime>{};

  void changed(DraftKey key) {
    _changedAt[key] = clock();
    _timers[key]?.cancel();
    _timers[key] = Timer(draftQuietTime, () {
      final at = _changedAt[key];
      if (at != null &&
          shouldPushDraft(lastChangeAt: at, now: clock(), leaving: false)) {
        _release(key);
      }
    });
  }

  /// The user left the draft: push it now if it waits.
  void flush(DraftKey key) {
    if (_changedAt.containsKey(key)) _release(key);
  }

  void flushAll() {
    for (final key in _changedAt.keys.toList()) {
      _release(key);
    }
  }

  void _release(DraftKey key) {
    _timers.remove(key)?.cancel();
    _changedAt.remove(key);
    push(key);
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _changedAt.clear();
  }
}

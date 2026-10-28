import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';

/// What the user has written but not sent in one conversation.
class Draft {
  const Draft({
    required this.channelId,
    this.rootId = '',
    this.message = '',
    this.selectionBase,
    this.selectionExtent,
    this.files = const [],
    this.priority,
  });

  final String channelId;

  /// Empty for the channel itself, else the thread's first post.
  final String rootId;
  final String message;

  /// The cursor or selection to restore, as text offsets.
  final int? selectionBase;
  final int? selectionExtent;

  /// Attachments already uploaded, so a restart doesn't upload them again.
  final List<api.FileInfo> files;
  final api.PostPriority? priority;

  bool get isEmpty => message.isEmpty && files.isEmpty;
}

/// Saves drafts a moment after the last change, so typing doesn't write on
/// every key; [flush] writes what is waiting at once.
class DraftSaver {
  DraftSaver(
    this.store, {
    this.delay = const Duration(milliseconds: 500),
    this.onWritten,
    this.onCleared,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerStore store;
  final Duration delay;

  /// Told after a draft was written or deleted, with its channel and root.
  final void Function(String channelId, String rootId)? onWritten;

  /// Told after a draft was deleted on purpose: sent, or removed from the
  /// list.
  final void Function(String channelId, String rootId)? onCleared;
  final DateTime Function() _clock;

  final _waiting = <(String, String), Draft>{};
  final _timers = <(String, String), Timer>{};

  Future<Draft?> load(String channelId, String rootId) async {
    final waiting = _waiting[(channelId, rootId)];
    if (waiting != null) return waiting;
    final row = await store.draft(channelId, rootId);
    return row == null ? null : _draftOf(row);
  }

  void save(Draft draft) {
    final key = (draft.channelId, draft.rootId);
    _waiting[key] = draft;
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, () => unawaited(_write(key)));
  }

  /// Forgets a waiting save, e.g. when the draft was just sent.
  void cancel(String channelId, String rootId) {
    final key = (channelId, rootId);
    _timers.remove(key)?.cancel();
    _waiting.remove(key);
  }

  Future<void> clear(String channelId, String rootId) async {
    cancel(channelId, rootId);
    await store.deleteDraft(channelId, rootId);
    onCleared?.call(channelId, rootId);
  }

  Future<void> flush() =>
      Future.wait([for (final key in _waiting.keys.toList()) _write(key)]);

  Future<void> _write((String, String) key) async {
    _timers.remove(key)?.cancel();
    final draft = _waiting.remove(key);
    if (draft == null) return;
    if (draft.isEmpty) {
      await store.deleteDraft(draft.channelId, draft.rootId);
    } else {
      await _save(draft);
    }
    onWritten?.call(draft.channelId, draft.rootId);
  }

  Future<void> _save(Draft draft) async {
    await store.saveDraft(
      DraftsCompanion.insert(
        channelId: draft.channelId,
        rootId: Value(draft.rootId),
        message: Value(draft.message),
        selectionBase: Value(draft.selectionBase),
        selectionExtent: Value(draft.selectionExtent),
        files: Value(draft.files),
        priority: Value(draft.priority),
        updatedAt: _clock(),
      ),
    );
  }

  Draft _draftOf(DraftRow row) {
    return Draft(
      channelId: row.channelId,
      rootId: row.rootId,
      message: row.message,
      selectionBase: row.selectionBase,
      selectionExtent: row.selectionExtent,
      files: row.files,
      priority: row.priority,
    );
  }

  /// Writes what is waiting; the timers die with it.
  Future<void> dispose() => flush();
}

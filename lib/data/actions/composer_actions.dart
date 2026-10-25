import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/outbox.dart';

/// What the user writes: sending posts through the outbox, drafts,
/// suggestions, slash commands and changes to existing posts. Writes go
/// through the store; screens follow from the database.
class ComposerActions {
  ComposerActions(this.session, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;

  ServerDatabase get _db => session.db;
  ServerStore get _store => session.store;

  DateTime? _lastQueuedAt;
  late final _drafts = DraftSaver(_store, clock: _clock);

  /// Queues a post and returns its pending id. It shows in the conversation
  /// at once (dimmed while unsent) and the conversation's draft is cleared.
  /// [files] are already uploaded.
  Future<String> send(
    String channelId, {
    String rootId = '',
    required String message,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
  }) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    _drafts.cancel(channelId, rootId);
    final at = _uniqueNow();
    final pendingPostId = pendingPostIdFor(me, at);
    await _store.queuePost(
      pendingPostId: pendingPostId,
      channelId: channelId,
      rootId: rootId,
      userId: me,
      message: message,
      createAt: at,
      files: files,
      priority: rootId.isEmpty ? priority : null,
    );
    unawaited(session.outbox.kick());
    return pendingPostId;
  }

  /// Two posts queued in the same millisecond would share a pending id.
  DateTime _uniqueNow() {
    var at = _clock();
    final last = _lastQueuedAt;
    if (last != null && !at.isAfter(last)) {
      at = last.add(const Duration(milliseconds: 1));
    }
    return _lastQueuedAt = at;
  }

  /// Sends a failed post again, keeping its place in the conversation.
  Future<void> retry(String pendingPostId) async {
    if (await _store.requeuePost(pendingPostId)) {
      unawaited(session.outbox.kick());
    }
  }

  /// Deletes an unsent post.
  Future<void> discard(String pendingPostId) =>
      _store.discardPost(pendingPostId);

  /// The conversation's draft, read once when it opens.
  Future<Draft?> loadDraft(String channelId, {String rootId = ''}) =>
      _drafts.load(channelId, rootId);

  /// Saves the draft 500 ms after the last change; an empty one is deleted.
  void saveDraft(Draft draft) => _drafts.save(draft);

  Future<void> clearDraft(String channelId, {String rootId = ''}) =>
      _drafts.clear(channelId, rootId);

  /// Writes waiting drafts now, e.g. when the app goes to the background.
  Future<void> flushDrafts() => _drafts.flush();

  Future<void> dispose() => _drafts.dispose();
}

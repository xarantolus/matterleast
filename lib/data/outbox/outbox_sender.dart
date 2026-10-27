import 'dart:async';
import 'dart:convert';

import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/outbox.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/log.dart';

/// A post the server will never take, removed from the conversation; the
/// screen tells the user once.
class PostRejected {
  const PostRejected({
    required this.pendingPostId,
    required this.channelId,
    this.message,
  });

  final String pendingPostId;
  final String channelId;

  /// The server's own words, when it gave any.
  final String? message;
}

/// Sends one server's queued posts, one at a time, first in first out per
/// channel, retrying with backoff while the server can't be reached. While
/// [offline] says so it waits for [wake] without using up attempts. The
/// queue lives in the database, so it survives the app being stopped.
class OutboxSender {
  OutboxSender({
    required this.server,
    required this.store,
    DateTime Function()? clock,
    bool Function()? offline,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       _offline = offline ?? _never;

  static bool _never() => false;

  final ServerApi server;
  final ServerStore store;
  final DateTime Function() _clock;
  final bool Function() _offline;

  final _rejected = StreamController<PostRejected>.broadcast();
  Timer? _timer;
  Future<void>? _running;
  var _again = false;
  var _started = false;
  var _closed = false;

  Stream<PostRejected> get rejected => _rejected.stream;

  /// Resumes what was queued before the app last stopped.
  Future<void> start() async {
    if (_started || _closed) return;
    _started = true;
    await store.resetSending();
    await kick();
  }

  /// The connection is back: waiting posts go at once.
  Future<void> wake() async {
    if (!_started || _closed) return;
    await store.sendWaitingNow();
    await kick();
  }

  /// Looks at the queue again, e.g. after a post was queued. Completes once
  /// everything that can go now has been tried.
  Future<void> kick() {
    if (!_started || _closed) return Future.value();
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _drain().whenComplete(() => _running = null);
  }

  Future<void> _drain() async {
    _timer?.cancel();
    do {
      _again = false;
      while (!_closed && !_offline()) {
        final rows = await store.outboxRows();
        final step = nextOutboxStep([
          for (final r in rows)
            (
              pendingPostId: r.pendingPostId,
              channelId: r.channelId,
              queuedAt: r.queuedAt,
              state: r.state,
              nextAttemptAt: r.nextAttemptAt,
            ),
        ], _clock());
        if (step is WaitUntil) {
          _timer?.cancel();
          _timer = Timer(step.at.difference(_clock()), () => unawaited(kick()));
        }
        if (step is! SendNow) break;
        await _send(
          rows.firstWhere((r) => r.pendingPostId == step.pendingPostId),
        );
      }
    } while (_again && !_closed);
  }

  Future<void> _send(OutboxRow row) async {
    final id = row.pendingPostId;
    final db = store.db;
    final post = await (db.select(
      db.posts,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (post == null) {
      await store.discardPost(id);
      return;
    }
    await store.markSending(id);
    final metadata = _metadata(post.metadataJson);
    final priority = _priority(
      metadata?.priority,
      acknowledgements: (await db.features()).acknowledgements,
    );
    final api.Post created;
    try {
      created = await server.call(
        () => server.client.posts.createPost(
          body: api.ApiV4PostsRequestBody(
            channelId: post.channelId,
            message: post.message,
            rootId: post.rootId.isEmpty ? null : post.rootId,
            fileIds: [
              for (final f in metadata?.files ?? const <api.FileInfo>[]) ?f.id,
            ],
            metadata: priority == null
                ? null
                : api.Metadata(priority: priority),
            pendingPostId: id,
            type: post.type.isEmpty ? null : post.type,
          ),
        ),
      );
    } on ApiError catch (e) {
      if (priority?.requestedAck == true && endpointUnavailable(e)) {
        await store.turnOff(OptionalFeature.acknowledgements);
      }
      if (post.type == burnOnReadType && endpointUnavailable(e)) {
        await store.turnOff(OptionalFeature.burnOnRead);
      }
      await _failed(row, e);
      return;
    }
    if (_closed) return;
    await store.applySent(id, created);
  }

  Future<void> _failed(OutboxRow row, ApiError error) async {
    final id = row.pendingPostId;
    if (error case Unreachable(noNetwork: true)) {
      await store.markSendRetry(
        id,
        attempts: row.attempts,
        nextAttemptAt: _clock(),
      );
      return;
    }
    final failures = row.attempts + 1;
    final message = error is ServerError ? error.message : null;
    switch (classifySendError(error, failures)) {
      case RetryLater(:final delay):
        if (failures == 1) Log.info('outbox', 'Sending failed; retrying');
        await store.markSendRetry(
          id,
          attempts: failures,
          nextAttemptAt: _clock().add(delay),
          error: message,
        );
      case GiveUp(:final message):
        Log.warn('outbox', 'Sending failed for good', error);
        await store.markSendFailed(id, attempts: failures, error: message);
      case DropPost(:final message):
        await store.discardPost(id);
        if (!_closed) {
          _rejected.add(
            PostRejected(
              pendingPostId: id,
              channelId: row.channelId,
              message: message,
            ),
          );
        }
    }
  }

  /// The priority to send; a request for acknowledgement goes only while
  /// the server takes them, so a retry after it said no still sends.
  static api.PostPriority? _priority(
    api.PostPriority? priority, {
    required bool acknowledgements,
  }) {
    if (priority == null || acknowledgements || priority.requestedAck != true) {
      return priority;
    }
    return api.PostPriority(
      priority: priority.priority,
      persistentNotifications: priority.persistentNotifications,
    );
  }

  api.PostMetadata? _metadata(String? json) {
    if (json == null) return null;
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?>
        ? api.PostMetadata.fromJson(decoded)
        : null;
  }

  Future<void> close() async {
    _closed = true;
    _timer?.cancel();
    await _running;
    await _rejected.close();
  }
}

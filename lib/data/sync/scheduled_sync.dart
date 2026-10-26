import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/server_features.dart';

/// The server's error id when scheduling needs a licence it doesn't have.
const _licenseError = 'api.scheduled_posts.license_error';

/// Messages scheduled to send later: the server's list mirrored into the
/// database, and the changes the user makes to it.
class ScheduledSync {
  ScheduledSync({required this.server, required this.store});

  final ServerApi server;
  final ServerStore store;

  ServerDatabase get _db => store.db;
  api.ScheduledPostClient get _client => server.client.scheduledPost;

  Future<bool> enabled() async => (await _db.features()).scheduledPosts;

  /// Replaces the stored scheduled messages of [teamId] and of direct
  /// messages with the server's.
  Future<void> fetch(String teamId) async {
    if (!await enabled()) return;
    final Map<String, List<api.ScheduledPost>> lists;
    try {
      lists = await server.call(
        () => _client.getUserScheduledPosts(
          teamId: teamId,
          includeDirectChannels: true,
        ),
      );
    } on ApiError catch (e) {
      if (await _unavailable(e)) return;
      rethrow;
    }
    await _db.transaction(() async {
      await (_db.delete(
        _db.scheduledPosts,
      )..where((s) => s.teamId.isIn([teamId, '']))).go();
      for (final MapEntry(:key, :value) in lists.entries) {
        for (final post in value) {
          await _upsert(post, teamId: key == teamId ? teamId : '');
        }
      }
    });
  }

  /// A `scheduled_post_*` event.
  Future<void> applyEvent(api.ScheduledPost post, {required bool deleted}) =>
      deleted ? _remove(post.id) : _upsert(post);

  /// Schedules a message for [at]; it shows in the list at once.
  Future<void> schedule({
    required String channelId,
    String rootId = '',
    required String message,
    required DateTime at,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
  }) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    final created = await _call(
      () => _client.createScheduledPost(
        body: api.ScheduledPost(
          userId: me,
          channelId: channelId,
          rootId: rootId,
          message: message,
          scheduledAt: at,
          fileIds: [for (final f in files) ?f.id],
          metadata: priority == null
              ? null
              : api.PostMetadata(priority: priority),
        ),
      ),
    );
    await _upsert(created);
  }

  /// Moves a scheduled message to [at]; a failed one is tried again then.
  Future<void> reschedule(String id, DateTime at) =>
      _update(id, (p) => {...p, 'scheduled_at': at.millisecondsSinceEpoch});

  Future<void> edit(String id, String message) =>
      _update(id, (p) => {...p, 'message': message});

  Future<void> delete(String id) async {
    await _call(() => _client.deleteScheduledPost(scheduledPostId: id));
    await _remove(id);
  }

  /// The stored copy of [id], as the server sent it.
  Future<api.ScheduledPost?> find(String id) async {
    final row = await (_db.select(
      _db.scheduledPosts,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    return row == null ? null : _decode(row.json);
  }

  Future<void> _update(
    String id,
    Map<String, Object?> Function(Map<String, Object?>) change,
  ) async {
    final current = await find(id);
    if (current == null) return;
    final changed = api.ScheduledPost.fromJson(
      change({...current.toJson(), 'error_code': ''}),
    );
    final updated = await _call(
      () => _client.updateScheduledPost(scheduledPostId: id, body: changed),
    );
    await _upsert(updated);
  }

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await server.call(request);
    } on ApiError catch (e) {
      await _unavailable(e);
      rethrow;
    }
  }

  Future<void> _upsert(api.ScheduledPost post, {String? teamId}) async {
    final id = post.id;
    final channelId = post.channelId;
    final at = post.scheduledAt;
    if (id == null || channelId == null || at == null) return;
    final team =
        teamId ??
        (await (_db.select(
          _db.channels,
        )..where((c) => c.id.equals(channelId))).getSingleOrNull())?.teamId ??
        '';
    await _db
        .into(_db.scheduledPosts)
        .insertOnConflictUpdate(
          ScheduledPostsCompanion.insert(
            id: id,
            teamId: Value(team),
            channelId: channelId,
            rootId: Value(post.rootId ?? ''),
            message: Value(post.message ?? ''),
            scheduledAt: at,
            updateAt: Value(post.updateAt),
            errorCode: Value(
              (post.errorCode?.isEmpty ?? true) ? null : post.errorCode,
            ),
            json: jsonEncode(post.toJson()),
          ),
        );
  }

  Future<void> _remove(String? id) async {
    if (id == null) return;
    await (_db.delete(_db.scheduledPosts)..where((s) => s.id.equals(id))).go();
  }

  /// Turns scheduling off for this session when the server says it has
  /// none, such as a server that lost its licence.
  Future<bool> _unavailable(ApiError e) async {
    final unlicensed = e is ServerError && e.id == _licenseError;
    if (!unlicensed && !endpointUnavailable(e)) return false;
    await store.turnOff(OptionalFeature.scheduledPosts);
    return true;
  }

  static api.ScheduledPost? _decode(String json) {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?>
        ? api.ScheduledPost.fromJson(decoded)
        : null;
  }
}

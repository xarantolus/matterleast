import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/draft_push_scheduler.dart';
import 'package:matterleast/domain/draft_sync.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/log.dart';

/// Keeps drafts on the server too where it allows it and the user didn't
/// turn it off, so their other devices see them. The drafts table stays the
/// one source the composer and the drafts list read.
class DraftSync {
  DraftSync({
    required this.server,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final DateTime Function() _clock;

  ServerDatabase get _db => store.db;
  api.UsersClient get _users => server.client.users;

  /// One request at a time per draft, so an older save can't land last.
  final _queues = <DraftKey, Future<void>>{};

  late final _waiting = DraftPushScheduler(
    clock: _clock,
    push: (key) => unawaited(changed(key.channelId, key.rootId)),
  );

  /// The user typed in the draft: the local copy is saved already, the
  /// server gets it once it has been quiet for [draftQuietTime], or at
  /// [flush].
  void changedSoon(String channelId, String rootId) =>
      _waiting.changed((channelId: channelId, rootId: rootId));

  /// The user left the draft's conversation: push it now if it waits.
  void flush(String channelId, String rootId) =>
      _waiting.flush((channelId: channelId, rootId: rootId));

  /// Pushes every waiting draft, e.g. when the app goes to the background.
  void flushAll() => _waiting.flushAll();

  Future<bool> enabled() async {
    if (!(await _db.features()).syncedDrafts) return false;
    return await _db.preference(Prefs.syncDrafts.$1, Prefs.syncDrafts.$2) !=
        'false';
  }

  /// The draft of [channelId] and [rootId] changed or went here: tell the
  /// server. A failure is caught up with on the next [pull].
  Future<void> changed(String channelId, String rootId) {
    final key = (channelId: channelId, rootId: rootId);
    final previous = _queues[key] ?? Future<void>.value();
    final next = previous.then((_) => _push(key));
    _queues[key] = next;
    return next.whenComplete(() {
      if (identical(_queues[key], next)) _queues.remove(key);
    });
  }

  /// Waits for pushes in flight, so closing doesn't leave one writing to a
  /// closed database; drafts still waiting for quiet stay local.
  Future<void> close() async {
    _waiting.dispose();
    await _drain();
  }

  Future<void> _drain() => Future.wait([
    for (final push in _queues.values.toList()) push.catchError((Object _) {}),
  ]);

  Future<void> _push(DraftKey key) async {
    try {
      if (!await enabled()) return;
      final row = await store.draft(key.channelId, key.rootId);
      if (row == null || _blank(row)) {
        await _db.setSyncInt(_deletedKey(key), _clock().millisecondsSinceEpoch);
        await _deleteOnServer(key);
      } else {
        await _send(row);
      }
    } on ApiError catch (e) {
      await _unavailable(e);
      Log.info('drafts', 'Draft not synced: $e');
    }
  }

  /// Brings this device's drafts in [teamId] (and in direct messages) and
  /// the server's together, the newer copy of each winning.
  Future<void> pull(String teamId) async {
    if (!await enabled()) return;
    final List<api.Draft> remote;
    try {
      // Not the generated call: a server with nothing to say answers null.
      final body = (await server.call(
        () => server.dio.get<Object?>('/api/v4/users/me/teams/$teamId/drafts'),
      )).data;
      remote = [
        if (body is List<Object?>)
          for (final e in body)
            if (e is Map<String, Object?>) ?decodeOrSkip(e, api.Draft.fromJson),
      ];
    } on ApiError catch (e) {
      if (await _unavailable(e)) return;
      rethrow;
    }
    final byKey = {
      for (final d in remote)
        if (d.channelId case final channelId? when d.updateAt != null)
          (channelId: channelId, rootId: d.rootId ?? ''): d,
    };
    final channels = {
      for (final c in await (_db.select(
        _db.channels,
      )..where((c) => c.teamId.equals(teamId) | c.teamId.equals(''))).get())
        c.id,
    };
    final local = await (_db.select(
      _db.drafts,
    )..where((d) => d.channelId.isIn(channels))).get();
    final deleted = await _deletedHere();
    final steps = planDraftSync(
      local: [
        for (final d in local)
          if (!_blank(d))
            (
              key: (channelId: d.channelId, rootId: d.rootId),
              updatedAt: d.updatedAt,
              syncedAt: d.syncedAt,
            ),
      ],
      server: {
        for (final MapEntry(:key, :value) in byKey.entries)
          key: value.updateAt!,
      },
      deleted: deleted,
    );
    for (final step in steps) {
      final key = step.key;
      switch (step) {
        case TakeServerDraft():
          await _store(byKey[key]!);
        case SendDraft():
          unawaited(changed(key.channelId, key.rootId));
        case DropDraft():
          await store.deleteDraft(key.channelId, key.rootId);
        case DeleteServerDraft():
          unawaited(
            _deleteOnServer(key).catchError((Object e) {
              Log.info('drafts', 'Draft not deleted: $e');
            }),
          );
      }
    }
    for (final key in deleted.keys) {
      if (!byKey.containsKey(key)) await _db.setSyncInt(_deletedKey(key), null);
    }
  }

  /// A `draft_created`, `draft_updated` or `draft_deleted` event.
  Future<void> applyEvent(api.Draft draft, {required bool deleted}) async {
    final channelId = draft.channelId;
    if (channelId == null || !await enabled()) return;
    final rootId = draft.rootId ?? '';
    final row = await store.draft(channelId, rootId);
    final local = row == null || _blank(row)
        ? null
        : (
            key: (channelId: channelId, rootId: rootId),
            updatedAt: row.updatedAt,
            syncedAt: row.syncedAt,
          );
    if (deleted) {
      if (serverDeleteWins(local)) await store.deleteDraft(channelId, rootId);
      return;
    }
    final updateAt = draft.updateAt;
    if (updateAt == null) return;
    if (row?.syncedAt == updateAt) return;
    if (serverDraftWins(updateAt, local)) await _store(draft);
  }

  Future<void> _send(DraftRow row) async {
    final saved = await server.call(
      () => _users.upsertDraft(
        body: api.DraftUpsertRequest(
          channelId: row.channelId,
          rootId: row.rootId,
          message: row.message,
          fileIds: [for (final f in row.files) ?f.id],
          priority: row.priority,
        ),
      ),
    );
    await _db.setSyncInt(
      _deletedKey((channelId: row.channelId, rootId: row.rootId)),
      null,
    );
    final at = saved?.updateAt;
    if (at == null) return;
    // Only when nothing was typed meanwhile; that newer text goes next.
    await (_db.update(_db.drafts)..where(
          (d) =>
              d.channelId.equals(row.channelId) &
              d.rootId.equals(row.rootId) &
              d.updatedAt.equalsValue(row.updatedAt),
        ))
        .write(DraftsCompanion(updatedAt: Value(at), syncedAt: Value(at)));
  }

  Future<void> _deleteOnServer(DraftKey key) async {
    if (key.rootId.isEmpty) {
      await server.call(
        () => _users.deleteDraft(userId: 'me', channelId: key.channelId),
      );
    } else {
      await server.call(
        () => _users.deleteDraftForThread(
          userId: 'me',
          channelId: key.channelId,
          threadId: key.rootId,
        ),
      );
    }
    await _db.setSyncInt(_deletedKey(key), null);
  }

  Future<void> _store(api.Draft draft) async {
    final at = draft.updateAt!;
    final files = draft.metadata?.files ?? const <api.FileInfo>[];
    await store.saveDraft(
      DraftsCompanion.insert(
        channelId: draft.channelId!,
        rootId: Value(draft.rootId ?? ''),
        message: Value(draft.message ?? ''),
        selectionBase: const Value(null),
        selectionExtent: const Value(null),
        files: Value([
          for (final f in files)
            if (f.deleteAt == null) f,
        ]),
        priority: Value(draft.priority ?? draft.metadata?.priority),
        updatedAt: at,
        syncedAt: Value(at),
      ),
    );
    await _db.setSyncInt(
      _deletedKey((channelId: draft.channelId!, rootId: draft.rootId ?? '')),
      null,
    );
  }

  /// Turns syncing off for this session when the server says it has none.
  Future<bool> _unavailable(ApiError e) async {
    if (!endpointUnavailable(e)) return false;
    await store.turnOff(OptionalFeature.syncedDrafts);
    return true;
  }

  Future<Map<DraftKey, DateTime>> _deletedHere() async {
    final rows = await (_db.select(
      _db.syncState,
    )..where((s) => s.key.like('$_deletedPrefix%'))).get();
    return {
      for (final r in rows)
        if (r.valueInt case final at?)
          ?_keyOf(r.key): DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
    };
  }

  static bool _blank(DraftRow row) =>
      row.message.trim().isEmpty && row.files.isEmpty;

  static const _deletedPrefix = 'draft_deleted:';

  static String _deletedKey(DraftKey key) =>
      '$_deletedPrefix${key.channelId}:${key.rootId}';

  static DraftKey? _keyOf(String stored) {
    final parts = stored.substring(_deletedPrefix.length).split(':');
    return parts.length == 2 ? (channelId: parts[0], rootId: parts[1]) : null;
  }
}

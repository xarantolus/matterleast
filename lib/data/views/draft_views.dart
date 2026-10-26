import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/drafts.dart';
import 'package:matterleast/domain/scheduled_posts.dart';
import 'package:matterleast/domain/teams.dart';

/// The drafts list from one server database.
class DraftViews {
  DraftViews(this.db);

  final ServerDatabase db;

  /// Drafts in [teamId]'s channels and in direct and group messages,
  /// newest first.
  Stream<List<DraftItem>> drafts(String teamId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.drafts,
        db.channels,
        db.myChannels,
        db.users,
        db.preferences,
        db.config,
      ]),
    ),
    () => _drafts(teamId),
    interval: const Duration(milliseconds: 300),
  ).distinct(listEquals);

  Future<List<DraftItem>> _drafts(String teamId) async {
    final where = await _where(teamId);
    final drafts = await (db.select(
      db.drafts,
    )..where((d) => d.channelId.isIn(where.channels.keys))).get();
    final people = await _people(where, [for (final d in drafts) d.channelId]);
    return buildDraftList(
      [
        for (final d in drafts)
          (
            channelId: d.channelId,
            rootId: d.rootId,
            message: d.message,
            files: d.files.length,
            updatedAt: d.updatedAt,
          ),
      ],
      channels: where.channels,
      myId: where.myId,
      people: people,
      nameFormat: await db.nameFormat(),
    );
  }

  /// Messages scheduled in [teamId]'s channels and in direct and group
  /// messages, failed ones first, then the soonest.
  Stream<List<ScheduledItem>> scheduled(String teamId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.scheduledPosts,
        db.channels,
        db.myChannels,
        db.users,
        db.preferences,
      ]),
    ),
    () => _scheduled(teamId),
    interval: const Duration(milliseconds: 300),
  ).distinct(listEquals);

  /// How many messages wait to be sent in a channel ([rootId] empty) or a
  /// thread.
  Stream<int> scheduledCount(String channelId, String rootId) {
    final count = db.scheduledPosts.id.count();
    return (db.selectOnly(db.scheduledPosts)
          ..addColumns([count])
          ..where(
            db.scheduledPosts.channelId.equals(channelId) &
                db.scheduledPosts.rootId.equals(rootId),
          ))
        .map((row) => row.read(count) ?? 0)
        .watchSingle()
        .distinct();
  }

  Future<List<ScheduledItem>> _scheduled(String teamId) async {
    final where = await _where(teamId);
    final posts = await (db.select(
      db.scheduledPosts,
    )..where((s) => s.channelId.isIn(where.channels.keys))).get();
    final people = await _people(where, [for (final p in posts) p.channelId]);
    return buildScheduledList(
      [
        for (final p in posts)
          (
            id: p.id,
            channelId: p.channelId,
            rootId: p.rootId,
            message: p.message,
            files: _fileCount(p.json),
            scheduledAt: p.scheduledAt,
            errorCode: p.errorCode,
          ),
      ],
      channels: where.channels,
      myId: where.myId,
      people: people,
      nameFormat: await db.nameFormat(),
    );
  }

  Future<({String myId, Map<String, ChannelInput> channels})> _where(
    String teamId,
  ) async {
    final myId = await db.syncText(SyncKeys.currentUserId) ?? '';
    final rows =
        await (db.select(
          db.channels,
        )..where((c) => c.teamId.equals(teamId) | c.teamId.equals(''))).join([
          innerJoin(
            db.myChannels,
            db.myChannels.channelId.equalsExp(db.channels.id),
          ),
        ]).get();
    return (
      myId: myId,
      channels: {
        for (final row in rows)
          row.readTable(db.channels).id: channelInputOf(
            row.readTable(db.channels),
            row.readTable(db.myChannels),
          ),
      },
    );
  }

  /// The people needed to name the direct messages among [channelIds].
  Future<Map<String, PersonInput>> _people(
    ({String myId, Map<String, ChannelInput> channels}) where,
    Iterable<String> channelIds,
  ) async {
    final myId = where.myId;
    final partnerIds = {
      myId,
      for (final id in channelIds)
        if (where.channels[id] case final c? when c.type == 'D')
          ?directPartnerId(c.name, myId),
    };
    final users = await (db.select(
      db.users,
    )..where((u) => u.id.isIn(partnerIds))).get();
    return {
      for (final u in users)
        u.id: (
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          status: u.status,
        ),
    };
  }

  static int _fileCount(String json) {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> && decoded['file_ids'] is List
        ? (decoded['file_ids']! as List).length
        : 0;
  }
}

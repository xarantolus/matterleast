import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/channel_input.dart';
import 'package:matterleast/domain/drafts.dart';
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
    final channels = {
      for (final row in rows)
        row.readTable(db.channels).id: channelInputOf(
          row.readTable(db.channels),
          row.readTable(db.myChannels),
        ),
    };
    final drafts = await (db.select(
      db.drafts,
    )..where((d) => d.channelId.isIn(channels.keys))).get();
    final partnerIds = {
      myId,
      for (final d in drafts)
        if (channels[d.channelId] case final c? when c.type == 'D')
          ?directPartnerId(c.name, myId),
    };
    final users = await (db.select(
      db.users,
    )..where((u) => u.id.isIn(partnerIds))).get();
    return buildDraftList(
      [
        for (final d in drafts)
          (
            channelId: d.channelId,
            rootId: d.rootId,
            message: d.message,
            files: _count(d.filesJson),
            updatedAt: d.updatedAt,
          ),
      ],
      channels: channels,
      myId: myId,
      people: {
        for (final u in users)
          u.id: (
            username: u.username,
            firstName: u.firstName,
            lastName: u.lastName,
            nickname: u.nickname,
            status: u.status,
          ),
      },
      nameFormat: await db.nameFormat(),
    );
  }

  static int _count(String json) {
    final decoded = jsonDecode(json);
    return decoded is List ? decoded.length : 0;
  }
}

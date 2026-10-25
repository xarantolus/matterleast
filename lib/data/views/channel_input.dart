import 'dart:convert';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/channel_list.dart';

/// A stored channel and the user's membership as the list rules read them.
ChannelInput channelInputOf(ChannelRow c, MyChannelRow m) => (
  id: c.id,
  type: c.type,
  name: c.name,
  displayName: c.displayName,
  archived: c.deleteAt != null,
  createAt: c.createAt,
  lastPostAt: c.lastPostAt,
  lastRootPostAt: c.lastRootPostAt,
  totalMsgCount: c.totalMsgCount,
  totalMsgCountRoot: c.totalMsgCountRoot,
  msgCount: m.msgCount,
  msgCountRoot: m.msgCountRoot,
  mentionCount: m.mentionCount,
  mentionCountRoot: m.mentionCountRoot,
  muted: _muted(m.notifyPropsJson),
  lastViewedAt: m.lastViewedAt,
);

/// Muted channels only count mentions as unread.
bool _muted(String? notifyPropsJson) {
  if (notifyPropsJson == null) return false;
  final decoded = jsonDecode(notifyPropsJson);
  if (decoded is! Map<String, Object?>) return false;
  return api.ChannelNotifyProps.fromJson(decoded).markUnread == 'mention';
}

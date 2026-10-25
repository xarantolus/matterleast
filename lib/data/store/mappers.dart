import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';

/// Pure mappings from API models to table companions. Fields the server did
/// not send stay absent, so an upsert never erases a known value.

Value<T> _opt<T extends Object>(T? value) =>
    value == null ? const Value.absent() : Value(value);

String? _json(Object? value) => value == null ? null : jsonEncode(value);

UsersCompanion userCompanion(api.User u) => UsersCompanion(
  id: Value(u.id!),
  username: Value(u.username ?? ''),
  nickname: _opt(u.nickname),
  firstName: _opt(u.firstName),
  lastName: _opt(u.lastName),
  position: _opt(u.position),
  locale: _opt(u.locale),
  isBot: Value(u.isBot ?? false),
  updateAt: _opt(u.updateAt),
  deleteAt: Value(u.deleteAt),
  lastPictureUpdate: _opt(u.lastPictureUpdate?.millisecondsSinceEpoch),
  timezoneJson: _opt(_json(u.timezone?.toJson())),
  propsJson: _opt(_json(u.props)),
);

TeamsCompanion teamCompanion(api.Team t) => TeamsCompanion(
  id: Value(t.id!),
  name: Value(t.name ?? ''),
  displayName: Value(t.displayName ?? t.name ?? ''),
  type: Value(t.type ?? 'O'),
  description: _opt(t.description),
  updateAt: _opt(t.updateAt),
  deleteAt: Value(t.deleteAt),
  lastTeamIconUpdate: _opt(t.lastTeamIconUpdate?.millisecondsSinceEpoch),
);

MyTeamsCompanion myTeamCompanion(api.TeamMember m) =>
    MyTeamsCompanion(teamId: Value(m.teamId!), roles: _opt(m.roles));

ChannelsCompanion channelCompanion(api.Channel c) => ChannelsCompanion(
  id: Value(c.id!),
  teamId: Value(c.teamId ?? ''),
  type: Value(c.type ?? 'O'),
  name: Value(c.name ?? ''),
  displayName: Value(c.displayName ?? ''),
  header: _opt(c.header),
  purpose: _opt(c.purpose),
  creatorId: _opt(c.creatorId),
  createAt: _opt(c.createAt),
  updateAt: _opt(c.updateAt),
  deleteAt: Value(c.deleteAt),
  lastPostAt: _opt(c.lastPostAt),
  lastRootPostAt: _opt(c.lastRootPostAt),
  totalMsgCount: _opt(c.totalMsgCount),
  totalMsgCountRoot: _opt(c.totalMsgCountRoot),
  shared: _opt(c.shared),
  groupConstrained: _opt(c.groupConstrained),
);

MyChannelsCompanion myChannelCompanion(api.ChannelMember m) =>
    MyChannelsCompanion(
      channelId: Value(m.channelId!),
      roles: _opt(m.roles),
      lastViewedAt: _opt(m.lastViewedAt),
      msgCount: _opt(m.msgCount),
      msgCountRoot: _opt(m.msgCountRoot),
      mentionCount: _opt(m.mentionCount),
      mentionCountRoot: _opt(m.mentionCountRoot),
      urgentMentionCount: _opt(m.urgentMentionCount),
      notifyPropsJson: _opt(_json(m.notifyProps?.toJson())),
      lastUpdateAt: _opt(m.lastUpdateAt),
    );

CategoriesCompanion categoryCompanion(
  api.SidebarCategoryWithChannels c,
  int order,
) => CategoriesCompanion(
  id: Value(c.id!),
  teamId: Value(c.teamId ?? ''),
  type: Value(c.type?.toJson() ?? 'custom'),
  displayName: Value(c.displayName ?? ''),
  sorting: _opt(c.sorting),
  sortOrder: Value(order),
  muted: _opt(c.muted),
);

PostsCompanion postCompanion(api.Post p) => PostsCompanion(
  id: Value(p.id!),
  channelId: Value(p.channelId!),
  rootId: Value(p.rootId ?? ''),
  userId: Value(p.userId ?? ''),
  createAt: Value(p.createAt!),
  updateAt: _opt(p.updateAt),
  editAt: Value(p.editAt),
  deleteAt: Value(p.deleteAt),
  type: Value(p.type ?? ''),
  message: Value(p.message ?? ''),
  isPinned: Value(p.isPinned ?? false),
  replyCount: _opt(p.replyCount),
  lastReplyAt: _opt(p.lastReplyAt),
  originalId: _opt(p.originalId),
  pendingPostId: _opt(p.pendingPostId),
  sendState: const Value(null),
  propsJson: Value(_json(p.props)),
  metadataJson: Value(_json(p.metadata?.toJson())),
  fileCount: Value(p.metadata?.files.length ?? p.fileIds.length),
  reactionCount: Value(p.metadata?.reactions.length ?? 0),
  participantIdsJson: p.participants.isEmpty
      ? const Value.absent()
      : Value(jsonEncode([for (final u in p.participants) ?u.id])),
);

FilesCompanion fileCompanion(api.FileInfo f, String postId) => FilesCompanion(
  id: Value(f.id!),
  postId: Value(f.postId ?? postId),
  name: Value(f.name ?? ''),
  extension: _opt(f.extensionValue),
  mimeType: _opt(f.mimeType),
  size: _opt(f.size),
  width: Value(f.width),
  height: Value(f.height),
  hasPreview: Value(f.hasPreviewImage ?? false),
  miniPreview: Value(_decodeBase64(f.miniPreview)),
  deleteAt: Value(f.deleteAt),
);

ReactionsCompanion reactionCompanion(api.Reaction r) => ReactionsCompanion(
  postId: Value(r.postId!),
  userId: Value(r.userId!),
  emojiName: Value(r.emojiName!),
  createAt: Value(r.createAt),
);

PreferencesCompanion preferenceCompanion(api.Preference p) =>
    PreferencesCompanion(
      category: Value(p.category!),
      name: Value(p.name ?? ''),
      value: Value(p.value ?? ''),
    );

RolesCompanion roleCompanion(api.Role r) => RolesCompanion(
  name: Value(r.name!),
  permissionsJson: Value(jsonEncode(r.permissions)),
);

ThreadsCompanion threadCompanion(api.UserThread t, String channelId) =>
    ThreadsCompanion(
      rootId: Value(t.id!),
      channelId: Value(channelId),
      lastReplyAt: _opt(t.lastReplyAt),
      lastViewedAt: _opt(t.lastViewedAt),
      replyCount: _opt(t.replyCount),
      unreadReplies: Value(t.unreadReplies ?? 0),
      unreadMentions: Value(t.unreadMentions ?? 0),
      isFollowing: const Value(true),
      participantIdsJson: Value(
        jsonEncode([for (final u in t.participants) ?u.id]),
      ),
    );

CustomEmojiCompanion emojiCompanion(api.Emoji e) => CustomEmojiCompanion(
  id: Value(e.id!),
  name: Value(e.name!),
  creatorId: _opt(e.creatorId),
  createAt: _opt(e.createAt),
  deleteAt: Value(e.deleteAt),
);

Uint8List? _decodeBase64(String? text) {
  if (text == null || text.isEmpty) return null;
  try {
    return base64Decode(text);
  } on FormatException {
    return null;
  }
}

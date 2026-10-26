import 'package:drift/drift.dart';
import 'package:matterleast/data/db/millis.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  TextColumn get firstName => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get position => text().withDefault(const Constant(''))();
  TextColumn get locale => text().nullable()();
  BoolColumn get isBot => boolean().withDefault(const Constant(false))();

  /// Space-separated system roles; null for a row stored before they were
  /// kept, which the user loader fetches again.
  TextColumn get roles => text().nullable()();
  IntColumn get updateAt => integer().map(const Millis()).nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();
  IntColumn get lastPictureUpdate => integer().nullable()();
  TextColumn get timezoneJson => text().nullable()();
  TextColumn get propsJson => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('offline'))();
  IntColumn get statusUpdatedAt => integer().map(const Millis()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TeamRow')
class Teams extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get type => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get updateAt => integer().map(const Millis()).nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();
  IntColumn get lastTeamIconUpdate => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MyTeamRow')
class MyTeams extends Table {
  TextColumn get teamId => text()();
  TextColumn get roles => text().withDefault(const Constant(''))();
  IntColumn get msgCount => integer().withDefault(const Constant(0))();
  IntColumn get mentionCount => integer().withDefault(const Constant(0))();
  IntColumn get msgCountRoot => integer().withDefault(const Constant(0))();
  IntColumn get mentionCountRoot => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {teamId};
}

@DataClassName('ChannelRow')
@TableIndex(name: 'channels_by_team', columns: {#teamId})
class Channels extends Table {
  TextColumn get id => text()();

  /// Empty for direct and group messages, which belong to the server.
  TextColumn get teamId => text().withDefault(const Constant(''))();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get header => text().withDefault(const Constant(''))();
  TextColumn get purpose => text().withDefault(const Constant(''))();
  TextColumn get creatorId => text().withDefault(const Constant(''))();
  IntColumn get createAt => integer().map(const Millis()).nullable()();
  IntColumn get updateAt => integer().map(const Millis()).nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();
  IntColumn get lastPostAt => integer().map(const Millis()).nullable()();
  IntColumn get lastRootPostAt => integer().map(const Millis()).nullable()();
  IntColumn get totalMsgCount => integer().withDefault(const Constant(0))();
  IntColumn get totalMsgCountRoot => integer().withDefault(const Constant(0))();
  BoolColumn get shared => boolean().withDefault(const Constant(false))();
  BoolColumn get groupConstrained =>
      boolean().withDefault(const Constant(false))();

  /// From the channel's stats, fetched when it is opened.
  IntColumn get memberCount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The user's own membership of a channel; the server's counters, mirrored.
@DataClassName('MyChannelRow')
class MyChannels extends Table {
  TextColumn get channelId => text()();
  TextColumn get roles => text().withDefault(const Constant(''))();
  IntColumn get lastViewedAt => integer().map(const Millis()).nullable()();
  IntColumn get msgCount => integer().withDefault(const Constant(0))();
  IntColumn get msgCountRoot => integer().withDefault(const Constant(0))();
  IntColumn get mentionCount => integer().withDefault(const Constant(0))();
  IntColumn get mentionCountRoot => integer().withDefault(const Constant(0))();
  IntColumn get urgentMentionCount =>
      integer().withDefault(const Constant(0))();
  BoolColumn get manuallyUnread =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notifyPropsJson => text().nullable()();
  IntColumn get lastUpdateAt => integer().map(const Millis()).nullable()();

  /// Watermark for `posts?since=`: the newest create, update or delete time
  /// received for this channel.
  IntColumn get postsFetchedAt => integer().map(const Millis()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {channelId};
}

@DataClassName('CategoryRow')
@TableIndex(name: 'categories_by_team', columns: {#teamId})
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get teamId => text()();
  TextColumn get type => text()();
  TextColumn get displayName => text()();
  TextColumn get sorting => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get muted => boolean().withDefault(const Constant(false))();

  /// Collapse state is kept on the device only, as the official app does.
  BoolColumn get collapsed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CategoryChannelRow')
class CategoryChannels extends Table {
  TextColumn get categoryId => text()();
  TextColumn get channelId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {categoryId, channelId};
}

@DataClassName('PostRow')
@TableIndex(name: 'posts_by_channel', columns: {#channelId, #createAt})
@TableIndex(name: 'posts_by_root', columns: {#rootId, #createAt})
@TableIndex(name: 'posts_by_pending', columns: {#pendingPostId})
class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get channelId => text()();
  TextColumn get rootId => text().withDefault(const Constant(''))();
  TextColumn get userId => text()();
  IntColumn get createAt => integer().map(const Millis())();
  IntColumn get updateAt => integer().map(const Millis()).nullable()();
  IntColumn get editAt => integer().map(const Millis()).nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();
  TextColumn get type => text().withDefault(const Constant(''))();
  TextColumn get message => text().withDefault(const Constant(''))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get replyCount => integer().withDefault(const Constant(0))();
  IntColumn get lastReplyAt => integer().map(const Millis()).nullable()();
  TextColumn get originalId => text().withDefault(const Constant(''))();
  TextColumn get pendingPostId => text().withDefault(const Constant(''))();

  /// Null once the server has it; `pending` or `failed` for our own unsent
  /// posts, which are ordinary rows so the list has one source.
  TextColumn get sendState => text().nullable()();
  TextColumn get propsJson => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get fileCount => integer().withDefault(const Constant(0))();
  IntColumn get reactionCount => integer().withDefault(const Constant(0))();

  /// Who replied to a root post, as a JSON list of user ids, when the
  /// server said (collapsed reply threads).
  TextColumn get participantIdsJson => text().nullable()();

  /// Set when the server's copy couldn't be read or stored: what went
  /// wrong, as an error type. The row keeps its place but no content, and
  /// the next fetch that reads it clears this.
  TextColumn get decodeProblem => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A contiguous stretch of loaded posts in a channel or thread. A screen only
/// shows posts inside the range it is anchored in, so a hole never looks like
/// "no messages".
@DataClassName('PostRangeRow')
@TableIndex(name: 'post_ranges_by_scope', columns: {#scope, #scopeId, #latest})
class PostRanges extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `channel` or `thread`.
  TextColumn get scope => text()();
  TextColumn get scopeId => text()();
  IntColumn get earliest => integer().map(const Millis())();
  IntColumn get latest => integer().map(const Millis())();

  /// No older posts exist (or the server won't serve them).
  BoolColumn get reachesStart => boolean().withDefault(const Constant(false))();
}

@DataClassName('ReactionRow')
@TableIndex(name: 'reactions_by_post', columns: {#postId})
class Reactions extends Table {
  TextColumn get postId => text()();
  TextColumn get userId => text()();
  TextColumn get emojiName => text()();
  IntColumn get createAt => integer().map(const Millis()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {postId, userId, emojiName};
}

@DataClassName('FileRow')
@TableIndex(name: 'files_by_post', columns: {#postId})
class Files extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get extension => text().withDefault(const Constant(''))();
  TextColumn get mimeType => text().withDefault(const Constant(''))();
  IntColumn get size => integer().withDefault(const Constant(0))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  BoolColumn get hasPreview => boolean().withDefault(const Constant(false))();
  BlobColumn get miniPreview => blob().nullable()();
  TextColumn get localPath => text().nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ThreadRow')
class Threads extends Table {
  TextColumn get rootId => text()();
  TextColumn get channelId => text()();
  IntColumn get lastReplyAt => integer().map(const Millis()).nullable()();
  IntColumn get lastViewedAt => integer().map(const Millis()).nullable()();
  IntColumn get replyCount => integer().withDefault(const Constant(0))();
  IntColumn get unreadReplies => integer().withDefault(const Constant(0))();
  IntColumn get unreadMentions => integer().withDefault(const Constant(0))();
  BoolColumn get isFollowing => boolean().withDefault(const Constant(false))();
  TextColumn get participantIdsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {rootId};
}

@DataClassName('ThreadTeamRow')
class ThreadTeams extends Table {
  TextColumn get teamId => text()();
  TextColumn get rootId => text()();

  @override
  Set<Column<Object>> get primaryKey => {teamId, rootId};
}

@DataClassName('ThreadSyncRow')
class ThreadSync extends Table {
  TextColumn get teamId => text()();
  IntColumn get earliest => integer().map(const Millis())();
  IntColumn get latest => integer().map(const Millis())();

  @override
  Set<Column<Object>> get primaryKey => {teamId};
}

@DataClassName('CustomEmojiRow')
@TableIndex(name: 'custom_emoji_by_name', columns: {#name}, unique: true)
class CustomEmoji extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get creatorId => text().withDefault(const Constant(''))();
  IntColumn get createAt => integer().map(const Millis()).nullable()();
  IntColumn get deleteAt => integer().map(const Millis()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PreferenceRow')
class Preferences extends Table {
  TextColumn get category => text()();
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {category, name};
}

@DataClassName('RoleRow')
class Roles extends Table {
  TextColumn get name => text()();
  TextColumn get permissionsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

@DataClassName('DraftRow')
class Drafts extends Table {
  TextColumn get channelId => text()();
  TextColumn get rootId => text().withDefault(const Constant(''))();
  TextColumn get message => text().withDefault(const Constant(''))();
  IntColumn get selectionBase => integer().nullable()();
  IntColumn get selectionExtent => integer().nullable()();
  TextColumn get filesJson => text().withDefault(const Constant('[]'))();
  TextColumn get priorityJson => text().nullable()();
  IntColumn get updatedAt => integer().map(const Millis())();

  @override
  Set<Column<Object>> get primaryKey => {channelId, rootId};
}

/// Delivery state of our own unsent posts; the post itself is a [Posts] row.
@DataClassName('OutboxRow')
class Outbox extends Table {
  TextColumn get pendingPostId => text()();
  TextColumn get channelId => text()();
  TextColumn get rootId => text().withDefault(const Constant(''))();
  IntColumn get queuedAt => integer().map(const Millis())();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAt => integer().map(const Millis()).nullable()();
  TextColumn get lastError => text().nullable()();

  /// `queued`, `sending` or `failed`.
  TextColumn get state => text().withDefault(const Constant('queued'))();

  @override
  Set<Column<Object>> get primaryKey => {pendingPostId};
}

/// Ordered id lists that are not channel history: `mentions`, `saved`,
/// `pinned:<channel>`, `files:<channel>`.
@DataClassName('PostListRow')
class PostLists extends Table {
  TextColumn get list => text()();
  TextColumn get postId => text()();
  IntColumn get rank => integer()();

  @override
  Set<Column<Object>> get primaryKey => {list, postId};
}

@DataClassName('SearchHistoryRow')
class SearchHistory extends Table {
  TextColumn get teamId => text()();
  TextColumn get term => text()();
  IntColumn get createdAt => integer().map(const Millis())();

  @override
  Set<Column<Object>> get primaryKey => {teamId, term};
}

/// Where the reader left a channel or thread, kept about 30 days.
@DataClassName('ViewStateRow')
class ViewStates extends Table {
  TextColumn get scope => text()();
  TextColumn get scopeId => text()();
  TextColumn get anchorPostId => text()();
  RealColumn get anchorOffsetPx => real().withDefault(const Constant(0))();
  IntColumn get savedAt => integer().map(const Millis())();

  @override
  Set<Column<Object>> get primaryKey => {scope, scopeId};
}

/// Watermarks and singletons: `current_user_id`, `current_team_id`,
/// `last_full_sync`, `channels_since:<team>`, `ws_connection_id`, …
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get key => text()();
  IntColumn get valueInt => integer().nullable()();
  TextColumn get valueText => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Server config and licence snapshots as JSON: `client_config`, `license`,
/// `retention_policy`.
@DataClassName('ConfigRow')
class Config extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  IntColumn get fetchedAt => integer().map(const Millis())();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

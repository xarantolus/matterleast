import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/bookmarks.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/profile_attributes.dart';

const _interval = Duration(milliseconds: 300);

/// A channel's bookmarks from one server database.
class BookmarkViews {
  BookmarkViews(this.db);

  final ServerDatabase db;

  /// The bar's bookmarks in order; empty when the server has none.
  Stream<List<Bookmark>> bookmarks(String channelId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([db.channelBookmarks, db.files, db.config]),
    ),
    () => _bookmarks(channelId),
    interval: _interval,
  ).distinct(_sameList);

  Future<List<Bookmark>> _bookmarks(String channelId) async {
    if (!(await db.features()).bookmarks) return const [];
    final query =
        db.select(db.channelBookmarks).join([
            leftOuterJoin(
              db.files,
              db.files.id.equalsExp(db.channelBookmarks.fileId),
            ),
          ])
          ..where(db.channelBookmarks.channelId.equals(channelId))
          ..orderBy([
            OrderingTerm.asc(db.channelBookmarks.sortOrder),
            OrderingTerm.asc(db.channelBookmarks.id),
          ]);
    return [
      for (final row in await query.get())
        if (row.readTable(db.channelBookmarks) case final b)
          Bookmark(
            id: b.id,
            channelId: b.channelId,
            displayName: b.displayName,
            sortOrder: b.sortOrder,
            isFile: b.type == 'file',
            linkUrl: b.linkUrl,
            imageUrl: b.imageUrl,
            emoji: b.emoji,
            changedAt: b.updateAt,
            file: switch (row.readTableOrNull(db.files)) {
              final f? => PostFile(
                id: f.id,
                name: f.name,
                extension: f.extension,
                mimeType: f.mimeType,
                size: f.size,
                width: f.width,
                height: f.height,
                hasPreview: f.hasPreview,
                miniPreview: f.miniPreview,
              ),
              null => null,
            },
          ),
    ];
  }

  /// What the user may do with [channelId]'s bookmarks.
  Stream<BookmarkRights> rights(String channelId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.channels,
        db.myChannels,
        db.myTeams,
        db.roles,
        db.syncState,
        db.config,
      ]),
    ),
    () async {
      if (!(await db.features()).bookmarks) return noBookmarkRights;
      final channel = await (db.select(
        db.channels,
      )..where((c) => c.id.equals(channelId))).getSingleOrNull();
      if (channel == null) return noBookmarkRights;
      final permissions = PermissionViews(db);
      return bookmarkRights(
        channel.type,
        archived: channel.deleteAt != null,
        guest: isGuest(await db.syncText(SyncKeys.currentUserRoles)),
        roles: await permissions.rolesIn(channelId),
        granted: await permissions.roleGrants(),
      );
    },
    interval: _interval,
  ).distinct();
}

/// Custom profile attributes from one server database.
class AttributeViews {
  AttributeViews(this.db);

  final ServerDatabase db;

  Stream<Object?> get _changes => db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.profileFields,
      db.profileValues,
      db.config,
      db.users,
    ]),
  );

  /// What [userId]'s profile shows; empty without the feature.
  Stream<List<ShownAttribute>> shown(String userId) => throttledWatch(
    _changes,
    () async {
      final (fields, values) = await _read(userId);
      if (fields.isEmpty) return const <ShownAttribute>[];
      final userIds = {
        for (final f in fields)
          if (f.kind == AttributeKind.user) ...?values[f.id],
      };
      final users = userIds.isEmpty
          ? const <UserRow>[]
          : await (db.select(db.users)..where((u) => u.id.isIn(userIds))).get();
      final format = await db.nameFormat();
      final names = {
        for (final u in users)
          u.id: personName((
            username: u.username,
            firstName: u.firstName,
            lastName: u.lastName,
            nickname: u.nickname,
            status: u.status,
          ), format),
      };
      return shownAttributes(fields, values, userName: (id) => names[id] ?? id);
    },
    interval: _interval,
  ).distinct(_sameList);

  /// The fields and [userId]'s values, for editing one's own; no fields
  /// without the feature.
  Stream<(List<AttributeField>, Map<String, List<String>>)> editable(
    String userId,
  ) => throttledWatch(_changes, () => _read(userId), interval: _interval);

  Future<(List<AttributeField>, Map<String, List<String>>)> _read(
    String userId,
  ) async {
    if (!(await db.features()).profileAttributes) {
      return (const <AttributeField>[], const <String, List<String>>{});
    }
    final fields = [
      for (final f in await db.select(db.profileFields).get())
        attributeField(id: f.id, name: f.name, type: f.type, attrs: f.attrs),
    ]..sort(compareFields);
    final values = {
      for (final v in await (db.select(
        db.profileValues,
      )..where((v) => v.userId.equals(userId))).get())
        v.fieldId: v.values,
    };
    return (fields, values);
  }
}

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

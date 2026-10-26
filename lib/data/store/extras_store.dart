import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/mappers.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/profile_attributes.dart';

/// Writes for channel bookmarks and custom profile attributes, kept apart
/// from the rest of [ServerStore] but going through its database the same
/// way: one transaction per change.
extension ExtrasStore on ServerStore {
  /// Bookmarks of [channelId] as the server sent them: new and changed ones
  /// are kept, deleted ones go, and the watermark for the next
  /// `bookmarks_since` moves to the newest change.
  Future<void> applyBookmarks(
    String channelId,
    Iterable<api.ChannelBookmarkWithFileInfo> bookmarks,
  ) => db.transaction(() async {
    var newest = await db.syncInt(SyncKeys.bookmarksSince(channelId)) ?? 0;
    for (final b in bookmarks) {
      final id = b.id;
      if (id == null || b.channelId != null && b.channelId != channelId) {
        continue;
      }
      for (final t in [b.createAt, b.updateAt, b.deleteAt]) {
        final ms = t?.millisecondsSinceEpoch ?? 0;
        if (ms > newest) newest = ms;
      }
      if (b.deleteAt != null) {
        await (db.delete(
          db.channelBookmarks,
        )..where((r) => r.id.equals(id))).go();
        continue;
      }
      final isFile = b.type == api.ChannelBookmarkType.file;
      if (b.type != api.ChannelBookmarkType.link && !isFile) continue;
      await db
          .into(db.channelBookmarks)
          .insertOnConflictUpdate(
            ChannelBookmarksCompanion.insert(
              id: id,
              channelId: channelId,
              displayName: b.displayName ?? '',
              sortOrder: Value(b.sortOrder ?? 0),
              type: isFile ? 'file' : 'link',
              linkUrl: Value(b.linkUrl),
              imageUrl: Value(b.imageUrl),
              emoji: Value(b.emoji),
              fileId: Value(isFile ? b.fileId ?? b.file?.id : null),
              updateAt: Value(b.updateAt ?? b.createAt),
            ),
          );
      if (b.file case final file? when isFile && file.id != null) {
        await db.into(db.files).insertOnConflictUpdate(fileCompanion(file, ''));
      }
    }
    await db.setSyncInt(SyncKeys.bookmarksSince(channelId), newest);
  });

  /// The bookmark was deleted here; the server's event may come later.
  Future<void> removeBookmark(String bookmarkId) => (db.delete(
    db.channelBookmarks,
  )..where((r) => r.id.equals(bookmarkId))).go();

  /// All custom profile attribute fields; fields no longer listed go.
  Future<void> applyProfileFields(List<api.PropertyField> fields) =>
      db.transaction(() async {
        await db.delete(db.profileFields).go();
        for (final f in fields) {
          await _upsertField(f);
        }
      });

  /// A field created, changed or deleted elsewhere.
  Future<void> applyProfileField(api.PropertyField field) =>
      _upsertField(field);

  Future<void> removeProfileField(String fieldId) => db.transaction(() async {
    await (db.delete(
      db.profileFields,
    )..where((f) => f.id.equals(fieldId))).go();
    await (db.delete(
      db.profileValues,
    )..where((v) => v.fieldId.equals(fieldId))).go();
  });

  Future<void> _upsertField(api.PropertyField f) async {
    final id = f.id;
    if (id == null) return;
    if (f.deleteAt != null) {
      await (db.delete(db.profileFields)..where((r) => r.id.equals(id))).go();
      return;
    }
    await db
        .into(db.profileFields)
        .insertOnConflictUpdate(
          ProfileFieldsCompanion.insert(
            id: id,
            name: f.name ?? '',
            type: f.type?.json ?? '',
            attrs: f.attrs ?? const {},
          ),
        );
  }

  /// A person's attribute values by field id. With [replace], fields not
  /// in [values] are cleared (a full fetch); otherwise only the given ones
  /// change (an update event).
  Future<void> applyProfileValues(
    String userId,
    Map<String, Object?> values, {
    bool replace = false,
  }) => db.transaction(() async {
    if (replace) {
      await (db.delete(
        db.profileValues,
      )..where((v) => v.userId.equals(userId))).go();
    }
    for (final MapEntry(key: fieldId, value: raw) in values.entries) {
      final list = attributeValues(raw);
      if (list.isEmpty) {
        await (db.delete(db.profileValues)..where(
              (v) => v.userId.equals(userId) & v.fieldId.equals(fieldId),
            ))
            .go();
      } else {
        await db
            .into(db.profileValues)
            .insertOnConflictUpdate(
              ProfileValuesCompanion.insert(
                userId: userId,
                fieldId: fieldId,
                values: list,
              ),
            );
      }
    }
  });
}

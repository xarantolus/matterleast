import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/profile_locks.dart';
import 'package:matterleast/domain/user_profile.dart';

/// People's profiles from one server database.
class ProfileViews {
  ProfileViews(this.db, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerDatabase db;
  final DateTime Function() _clock;

  Stream<UserProfile?> profile(String userId) => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.users,
        db.syncState,
        db.config,
        db.preferences,
      ]),
    ),
    () => _profile(userId),
    interval: const Duration(milliseconds: 300),
  ).distinct();

  /// The profile fields the signed-in user can't change here.
  Stream<ProfileLocks> locks() => throttledWatch(
    db.tableUpdates(TableUpdateQuery.onAllTables([db.syncState, db.config])),
    () async {
      final features = await db.features();
      return profileLocks(
        await db.syncText(SyncKeys.currentUserAuthService) ?? '',
        ldap: features.ldapFields,
        saml: features.samlFields,
      );
    },
    interval: const Duration(milliseconds: 300),
  ).distinct();

  Stream<List<CustomStatus>> recentStatuses() =>
      (db.select(db.preferences)..where(
            (p) =>
                p.category.equals(Prefs.recentCustomStatuses.$1) &
                p.name.equals(Prefs.recentCustomStatuses.$2),
          ))
          .watchSingleOrNull()
          .map((p) => recentCustomStatuses(p?.value));

  Future<UserProfile?> _profile(String userId) async {
    final u = await (db.select(
      db.users,
    )..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (u == null) return null;
    final timezone = _object(u.timezoneJson);
    final zone = timezone == null ? null : api.Timezone.fromJson(timezone);
    return UserProfile(
      id: u.id,
      name: personName((
        username: u.username,
        firstName: u.firstName,
        lastName: u.lastName,
        nickname: u.nickname,
        status: u.status,
      ), await db.nameFormat()),
      username: u.username,
      nickname: u.nickname,
      firstName: u.firstName,
      lastName: u.lastName,
      position: u.position,
      status: u.status,
      pictureUpdate: u.lastPictureUpdate,
      timezone: timezoneName(
        useAutomatic: zone?.useAutomaticTimezone,
        automatic: zone?.automaticTimezone,
        manual: zone?.manualTimezone,
      ),
      customStatus: (await db.features()).customStatus
          ? customStatusOf(_object(u.propsJson), _clock())
          : null,
      isBot: u.isBot,
      isMe: await db.syncText(SyncKeys.currentUserId) == u.id,
    );
  }

  static Map<String, Object?>? _object(String? json) {
    if (json == null) return null;
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : null;
  }
}

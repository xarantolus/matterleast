import 'dart:convert';
import 'dart:io';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/user_profile.dart';

/// What the user changes about themself, and fetching someone's profile.
/// Status changes show at once and are put back when the server refuses.
class ProfileActions {
  ProfileActions(this.session);

  final ServerSession session;

  static const timeout = Duration(seconds: 15);

  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  Future<String> _myId() async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('No signed-in user');
    return me;
  }

  /// Someone's profile and presence, fresh from the server.
  Future<void> refresh(String userId) =>
      session.api.coalesced('profile:$userId', () async {
        final user = session.api
            .call(() => _client.users.getUser(userId: userId))
            .timeout(timeout);
        final status = session.api
            .call(() => _client.status.getUserStatus(userId: userId))
            .timeout(timeout);
        await session.store.applyUsers([await user]);
        if ((await status).status case final s?) {
          await session.store.applyStatuses({userId: s});
        }
      });

  /// Sets the user's presence; [dndEnd] ends do-not-disturb at that time.
  Future<void> setStatus(String status, {DateTime? dndEnd}) async {
    final me = await _myId();
    final before = (await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(me))).getSingle()).status;
    await session.store.applyStatuses({me: status});
    try {
      await session.api
          .call(
            () => _client.status.updateUserStatus(
              userId: me,
              body: api.ApiV4UsersUserIdStatusRequestBody(
                userId: me,
                status: status,
                dndEndTime: dndEnd == null
                    ? null
                    : dndEnd.millisecondsSinceEpoch ~/ 1000,
              ),
            ),
          )
          .timeout(timeout);
    } on Object {
      await session.store.applyStatuses({me: before});
      rethrow;
    }
  }

  /// Sets the custom status, or clears it with null.
  Future<void> setCustomStatus(CustomStatus? status) async {
    final me = await _myId();
    final row = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(me))).getSingle();
    final before = row.propsJson;
    final props = {...?_object(before)};
    if (status == null) {
      props.remove('customStatus');
    } else {
      props['customStatus'] = jsonEncode(status.toJson());
    }
    await session.store.applyUserProps(me, jsonEncode(props));
    try {
      await session.api
          .call(
            () => status == null
                ? _client.status.unsetUserCustomStatus(userId: me)
                : _client.status.updateUserCustomStatus(
                    userId: me,
                    body: api.ApiV4UsersUserIdStatusCustomRequestBody(
                      emoji: status.emoji,
                      text: status.text,
                      duration: status.duration,
                      expiresAt: status.expiresAt?.toUtc().toIso8601String(),
                    ),
                  ),
          )
          .timeout(timeout);
    } on Object {
      await session.store.applyUserProps(me, before);
      rethrow;
    }
  }

  /// Changes the user's names, nickname, position or username; null leaves
  /// a field as it is.
  Future<void> patchMe({
    String? firstName,
    String? lastName,
    String? nickname,
    String? position,
    String? username,
  }) async {
    final user = await session.api
        .call(
          () => _client.users.patchUser(
            userId: 'me',
            body: api.ApiV4UsersUserIdPatchRequestBody(
              firstName: firstName,
              lastName: lastName,
              nickname: nickname,
              position: position,
              username: username,
            ),
          ),
        )
        .timeout(timeout);
    await session.store.applyMe(user);
  }

  /// Uploads a new profile picture.
  Future<void> setPicture(File image) async {
    final me = await _myId();
    await session.api
        .call(() => _client.users.setProfileImage(userId: me, image: image))
        .timeout(const Duration(minutes: 3));
    await session.store.applyMe(
      await session.api.call(() => _client.users.getUser(userId: 'me')),
    );
  }

  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    final me = await _myId();
    await session.api
        .call(
          () => _client.users.updateUserPassword(
            userId: me,
            body: api.ApiV4UsersUserIdPasswordRequestBody(
              currentPassword: current,
              newPassword: next,
            ),
          ),
        )
        .timeout(timeout);
  }

  static Map<String, Object?>? _object(String? json) {
    if (json == null) return null;
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : null;
  }
}

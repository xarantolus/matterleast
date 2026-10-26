import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/extras_store.dart';
import 'package:matterleast/domain/profile_attributes.dart';
import 'package:matterleast/domain/server_features.dart';

/// Custom profile attributes: the server's fields, people's values and the
/// user's own changes.
class AttributeActions {
  AttributeActions(this.session);

  final ServerSession session;

  api.CustomProfileAttributesClient get _client =>
      session.api.client.customProfileAttributes;

  /// The fields and [userId]'s values, fresh from the server; nothing when
  /// the server has no profile attributes.
  Future<void> refresh(String userId) async {
    if (!(await session.db.features()).profileAttributes) return;
    try {
      final fields = await session.api.coalesced(
        'profile-fields',
        _client.listAllCpaFields,
      );
      await session.store.applyProfileFields(fields);
    } on Object catch (e) {
      // A server from before profile attributes has no such route.
      await _turnOffIfAbsent(e, missingRoute: true);
      rethrow;
    }
    try {
      // The answer holds a string or a list per field, which the generated
      // client can't type; read it as the JSON object it is.
      final values = await session.api.coalesced(
        'profile-values:$userId',
        () => session.api.getJsonObject(
          '/api/v4/users/$userId/custom_profile_attributes',
        ),
      );
      await session.store.applyProfileValues(
        userId,
        values ?? const {},
        replace: true,
      );
    } on Object catch (e) {
      await _turnOffIfAbsent(e);
      rethrow;
    }
  }

  /// Saves the user's own values: field id to what they entered.
  Future<void> saveMine(Map<AttributeField, List<String>> changes) async {
    if (changes.isEmpty) return;
    final me = await session.db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('No signed-in user');
    try {
      final saved = await session.api.call(
        () => _client.patchCpaValuesForUser(
          userId: me,
          body: [
            for (final MapEntry(key: field, value: values) in changes.entries)
              api.ApiV4UsersUserIdCustomProfileAttributesRequestBody(
                id: field.id,
                value: attributeServerValue(field, values),
              ),
          ],
        ),
      );
      await session.store.applyProfileValues(me, {
        for (final v in saved) ?v.id: v.value,
      });
    } on Object catch (e) {
      await _turnOffIfAbsent(e);
      rethrow;
    }
  }

  Future<void> _turnOffIfAbsent(Object e, {bool missingRoute = false}) async {
    if (endpointUnavailable(e) ||
        missingRoute && e is ServerError && e.statusCode == 404) {
      await session.store.turnOff(OptionalFeature.profileAttributes);
    }
  }
}

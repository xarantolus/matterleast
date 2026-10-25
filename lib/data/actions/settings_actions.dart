import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/preference_keys.dart';

/// The user's account settings on one server. Each save goes to the server
/// first, so a refusal leaves everything as it was and the error reaches
/// the screen.
class SettingsActions {
  SettingsActions(this.session);

  final ServerSession session;

  Future<String> _me() async {
    final me = await session.db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    return me;
  }

  /// The notification settings as the server has them now.
  Future<NotifyProps> notifyProps() async {
    final me = await session.api.getJsonObject('/api/v4/users/me');
    return NotifyProps.fromJson(me?['notify_props']);
  }

  Future<NotifyProps> saveNotifyProps(NotifyProps props) async {
    final response = await session.api.call(
      () => session.api.dio.put<Map<String, Object?>>(
        '/api/v4/users/me/patch',
        data: {'notify_props': props.raw},
      ),
    );
    return NotifyProps.fromJson(response.data?['notify_props']);
  }

  /// Saves a display preference. Turning collapsed reply threads on or off
  /// fetches channels and threads again in the new shape.
  Future<void> savePreference((String, String) key, String value) async {
    final me = await _me();
    final preference = api.Preference(
      userId: me,
      category: key.$1,
      name: key.$2,
      value: value,
    );
    await session.api.call(
      () => session.api.client.preferences.updatePreferences(
        userId: me,
        body: [preference],
      ),
    );
    if (await session.store.applyPreferencesCheckingThreads([preference])) {
      session.connection.refreshAll();
    }
  }

  Future<void> setCollapsedThreads(bool on) =>
      savePreference(Prefs.collapsedThreads, on ? 'on' : 'off');

  Future<void> setNameFormat(NameFormat format) =>
      savePreference(Prefs.nameFormat, format.value);
}

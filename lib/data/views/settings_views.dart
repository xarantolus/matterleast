import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/people.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/domain/teams.dart';

/// What the Display page shows for one server.
typedef DisplayPrefs = ({
  bool threadsOn,
  bool threadsChangeable,
  NameFormat nameFormat,
  bool nameFormatLocked,
});

/// The reads behind the account settings and the server's theme.
class SettingsViews {
  SettingsViews(this.db);

  final ServerDatabase db;

  /// The account's notification settings as stored; empty until the first
  /// sign-in data arrived.
  Stream<NotifyProps> notifyProps() => db
      .watchSyncText(SyncKeys.accountNotifyProps)
      .map(NotifyProps.fromJsonText)
      .distinct((a, b) => mapEquals(a.raw, b.raw));

  Stream<DisplayPrefs> displayPrefs() async* {
    final watch = db
        .customSelect('SELECT 1', readsFrom: {db.preferences, db.config})
        .watch();
    await for (final _ in watch) {
      final features = await db.features();
      final threadSetting = features.collapsedThreads;
      yield (
        threadsOn: collapsedThreadsOn(
          threadSetting,
          await db.preference(
            Prefs.collapsedThreads.$1,
            Prefs.collapsedThreads.$2,
          ),
        ),
        threadsChangeable:
            threadSetting == 'default_on' || threadSetting == 'default_off',
        nameFormat: await db.nameFormat(),
        nameFormatLocked: features.nameDisplayLocked,
      );
    }
  }

  /// The user's Mattermost theme for the current team.
  Stream<ServerPalettes> palettes() => throttledWatch(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([db.preferences, db.syncState]),
    ),
    _palettes,
    interval: const Duration(milliseconds: 300),
  ).distinct();

  Future<ServerPalettes> _palettes() async {
    final rows = await (db.select(
      db.preferences,
    )..where((p) => p.category.equals('theme'))).get();
    final themes = {for (final row in rows) row.name: row.value};
    final team = await db.syncText(SyncKeys.currentTeamId);
    return (
      light: ServerPalette.of(themeForTeam(themes, team, dark: false)),
      dark: ServerPalette.of(themeForTeam(themes, team, dark: true)),
    );
  }
}

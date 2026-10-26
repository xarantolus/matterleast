import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/data/wait_limited.dart';
import 'package:matterleast/domain/quick_switch.dart';

/// Asks one server for people and public channels matching a term, for the
/// quick switcher. People found are stored, so they show locally next time
/// and their presence can be polled.
class SwitchSearch {
  SwitchSearch(this.session, {required this.serverUrl});

  final ServerSession session;
  final String serverUrl;

  ServerDatabase get _db => session.db;

  Future<List<SwitchItem>> search(String term) {
    final query = normalizeTerm(term);
    if (query.isEmpty) return Future.value(const []);
    return session.api.coalesced(
      'switch:$query',
      () => _search(query, peopleOnly: term.trim().startsWith('@')),
    );
  }

  Future<List<SwitchItem>> _search(
    String query, {
    required bool peopleOnly,
  }) async {
    final team = await _db.syncText(SyncKeys.currentTeamId);
    final users = session.api.call(
      () => session.api.client.users.searchUsers(
        body: api.ApiV4UsersSearchRequestBody(
          term: query,
          allowInactive: false,
          limit: 20,
        ),
      ),
    );
    final teamIds = peopleOnly
        ? const <String>[]
        : [for (final t in await _db.select(_db.myTeams).get()) t.teamId];
    final channels = waitLimited(
      teamIds,
      (teamId) => session.api.call(
        () => session.api.client.channels.autocompleteChannelsForTeam(
          teamId: teamId,
          name: query,
        ),
      ),
    ).then((lists) => lists.expand((l) => l));
    final found = await users;
    await session.store.applyUsers(found);
    final format = await _db.nameFormat();
    final me = await _db.syncText(SyncKeys.currentUserId);
    final ids = [
      for (final u in found)
        if (u.id != null && u.id != me && u.isBot != true) u.id!,
    ];
    final rows = await (_db.select(
      _db.users,
    )..where((u) => u.id.isIn(ids))).get();
    final joined = {
      for (final m in await _db.select(_db.myChannels).get()) m.channelId,
    };
    final teams = {
      for (final t in await _db.select(_db.teams).get()) t.id: t.displayName,
    };
    return [
      for (final u in rows) personItem(u, serverUrl, format, teamId: team),
      for (final c in await channels)
        if (c.id != null &&
            c.type == 'O' &&
            c.deleteAt == null &&
            !joined.contains(c.id))
          SwitchItem(
            serverUrl: serverUrl,
            kind: SwitchKind.joinable,
            id: c.id!,
            title: c.displayName ?? c.name ?? '',
            subtitle: teams[c.teamId],
            keys: [?c.name],
            handle: c.name,
            teamId: c.teamId,
          ),
    ];
  }
}

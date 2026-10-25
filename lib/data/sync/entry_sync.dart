import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/log.dart';

/// Brings a server's database up to date after sign-in, at launch and after
/// the WebSocket lost events: the entry data and the current team's
/// channels first, everything else behind it at lower priority.
class EntrySync {
  EntrySync({
    required this.server,
    required this.store,
    required this.runner,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final DateTime Function() _clock;

  ServerDatabase get _db => store.db;
  api.MattermostClient get _client => server.client;

  /// Resolves when the entry data and the current team are stored; the
  /// deferred work keeps running behind it.
  Future<void> run() => runner.enqueue(
    SyncJob(
      key: 'entry',
      priority: SyncPriority.p0,
      timeout: const Duration(seconds: 60),
      run: _entry,
    ),
  );

  /// Channels, memberships and categories of [teamId], e.g. when the user
  /// switches to it.
  Future<void> refreshTeam(
    String teamId, {
    SyncPriority priority = SyncPriority.p0,
  }) => runner.enqueue(
    SyncJob(key: 'team:$teamId', priority: priority, run: () => _team(teamId)),
  );

  /// Stores a team the user just joined, then its channels.
  Future<void> joinedTeam(String teamId) => runner.enqueue(
    SyncJob(
      key: 'join:$teamId',
      run: () async {
        final team = server.call(() => _client.teams.getTeam(teamId: teamId));
        final member = server.call(
          () => _client.teams.getTeamMember(teamId: teamId, userId: 'me'),
        );
        await Future.wait<Object?>([team, member]);
        await store.applyTeams([await team], [await member]);
        unawaited(
          refreshTeam(
            teamId,
            priority: SyncPriority.p1,
          ).catchError((Object _) {}),
        );
      },
    ),
  );

  Future<void> _entry() async {
    final started = _clock();
    final config = server.clientConfig();
    final license = server.clientLicense();
    final preferences = server.call(
      () => _client.preferences.getPreferences(userId: 'me'),
    );
    final me = server.coalesced(
      'me',
      () => _client.users.getUser(userId: 'me'),
    );
    final teams = server.call(
      () => _client.teams.getTeamsForUser(userId: 'me'),
    );
    final members = server.call(
      () => _client.teams.getTeamMembersForUser(userId: 'me'),
    );
    await Future.wait<Object?>([
      config,
      license,
      preferences,
      me,
      teams,
      members,
    ]);
    await store.applyEntry(
      config: await config,
      license: await license,
      preferences: await preferences,
      me: await me,
      teams: await teams,
      members: await members,
    );

    final joined = await _joinedTeams();
    final teamId = pickCurrentTeam(
      joined,
      current: await _db.syncText(SyncKeys.currentTeamId),
      teamsOrder: await _db.preference(
        Prefs.teamsOrder.$1,
        Prefs.teamsOrder.$2,
      ),
    );
    if (teamId != null) {
      await store.setCurrentTeam(teamId);
      await _team(teamId);
    }
    await _db.setSyncInt(SyncKeys.lastFullSync, started.millisecondsSinceEpoch);
    _deferred(teamId, joined, (await me).roles ?? '');
  }

  Future<List<TeamName>> _joinedTeams() async {
    final rows = await _db.select(_db.teams).join([
      innerJoin(_db.myTeams, _db.myTeams.teamId.equalsExp(_db.teams.id)),
    ]).get();
    return [
      for (final row in rows)
        (
          id: row.readTable(_db.teams).id,
          displayName: row.readTable(_db.teams).displayName,
        ),
    ];
  }

  Future<void> _team(String teamId) async {
    final started = _clock();
    final since = await _db.syncInt(SyncKeys.channelsSince(teamId)) ?? 0;
    final channels = server.call(
      () => _client.channels.getChannelsForTeamForUser(
        userId: 'me',
        teamId: teamId,
        includeDeleted: true,
        lastDeleteAt: since,
      ),
    );
    final members = server.call(
      () => _client.channels.getChannelMembersForUser(
        userId: 'me',
        teamId: teamId,
      ),
    );
    final categories = server.call(
      () => _client.channels.getSidebarCategoriesForTeamForUser(
        userId: 'me',
        teamId: teamId,
      ),
    );
    await Future.wait<Object?>([channels, members, categories]);
    await store.applyTeamChannels(
      teamId: teamId,
      channels: await channels,
      members: await members,
      categories: await categories,
      syncedAt: started,
    );
  }

  void _deferred(String? currentTeam, List<TeamName> teams, String myRoles) {
    void later(String key, SyncPriority priority, Future<void> Function() run) {
      unawaited(
        runner
            .enqueue(SyncJob(key: key, priority: priority, run: run))
            .catchError((Object _) {}),
      );
    }

    later('profiles', SyncPriority.p1, _directProfiles);
    later('team_unreads', SyncPriority.p1, _teamUnreads);
    if (currentTeam != null) {
      later(
        'threads:$currentTeam',
        SyncPriority.p1,
        () => _threads(currentTeam),
      );
    }
    for (final team in teams) {
      if (team.id == currentTeam) continue;
      later('team:${team.id}', SyncPriority.p1, () => _team(team.id));
    }
    later('roles', SyncPriority.p3, () => _roles(myRoles));
  }

  Future<void> _teamUnreads() async {
    final unreads = await server.call(
      () => _client.teams.getTeamsUnreadForUser(
        userId: 'me',
        includeCollapsedThreads: true,
      ),
    );
    await store.applyTeamUnreads(unreads);
  }

  /// Profiles of direct message partners we don't have yet, so their rows
  /// show a name and presence.
  Future<void> _directProfiles() async {
    final myId = await _db.syncText(SyncKeys.currentUserId);
    if (myId == null) return;
    final direct = await (_db.select(
      _db.channels,
    )..where((c) => c.type.equals('D'))).get();
    final partners = {for (final c in direct) ?directPartnerId(c.name, myId)};
    final known = {
      for (final u in await (_db.select(
        _db.users,
      )..where((u) => u.id.isIn(partners))).get())
        u.id,
    };
    final missing = partners.difference(known).toList();
    for (var i = 0; i < missing.length; i += 100) {
      final chunk = missing.sublist(i, (i + 100).clamp(0, missing.length));
      await store.applyUsers(
        await server.call(() => _client.users.getUsersByIds(body: chunk)),
      );
    }
  }

  Future<void> _threads(String teamId) async {
    final config = await _db.configJson('client_config');
    final crt = collapsedThreadsOn(
      config['CollapsedThreads'] as String?,
      await _db.preference(
        Prefs.collapsedThreads.$1,
        Prefs.collapsedThreads.$2,
      ),
    );
    if (!crt) return;
    final threads = await server.call(
      () => _client.threads.getUserThreads(
        userId: 'me',
        teamId: teamId,
        unread: true,
        perPage: 200,
      ),
    );
    await store.applyThreads(teamId, threads.threads, allUnread: true);
  }

  Future<void> _roles(String myRoles) async {
    final names = <String>{
      ...myRoles.split(' '),
      for (final t in await _db.select(_db.myTeams).get())
        ...t.roles.split(' '),
      for (final c in await _db.select(_db.myChannels).get())
        ...c.roles.split(' '),
    }..removeWhere((n) => n.isEmpty);
    final missing = names.difference(await store.roleNames()).toList();
    if (missing.isEmpty) return;
    try {
      await store.applyRoles(
        await server.call(() => _client.roles.getRolesByNames(body: missing)),
      );
    } on ApiError catch (e) {
      Log.warn('sync', 'Roles not loaded', e);
    }
  }
}

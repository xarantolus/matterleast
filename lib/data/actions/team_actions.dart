import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/teams.dart';

/// Joining and leaving teams, and what the user may do in one.
class TeamActions {
  TeamActions(this.session);

  final ServerSession session;

  api.MattermostClient get _client => session.api.client;

  Future<String> _me() async {
    final me = await session.db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    return me;
  }

  /// The teams the user could join: open teams they aren't in yet.
  Future<List<JoinableTeam>> joinable() async {
    final teams = <api.Team>[];
    for (var page = 0; ; page++) {
      final batch = await session.api.call(
        () => _client.teams.getAllTeams(page: page, perPage: 200),
      );
      teams.addAll(batch);
      if (batch.length < 200 || page >= 9) break;
    }
    final mine = {
      for (final row in await session.db.select(session.db.myTeams).get())
        row.teamId,
    };
    return joinableTeams([
      for (final t in teams)
        (
          id: t.id ?? '',
          displayName: t.displayName ?? t.name ?? '',
          description: t.description ?? '',
          deleted: (t.deleteAt?.millisecondsSinceEpoch ?? 0) > 0,
        ),
    ], mine);
  }

  /// Joins [teamId]; completes once the team is stored, its channels
  /// follow behind.
  Future<void> join(String teamId) async {
    final me = await _me();
    await session.api.call(
      () => _client.teams.addTeamMember(
        teamId: teamId,
        body: api.ApiV4TeamsTeamIdMembersRequestBody(
          teamId: teamId,
          userId: me,
        ),
      ),
    );
    await session.connection.entry.joinedTeam(teamId);
  }

  Future<void> leave(String teamId) async {
    final me = await _me();
    await session.api.call(
      () => _client.teams.removeTeamMember(teamId: teamId, userId: me),
    );
    await session.store.removeTeam(teamId);
    session.connection.refreshAll();
  }

  /// The link that lets people sign up into [teamId], or null when the
  /// server doesn't give this user the team's invite id.
  Future<Uri?> inviteLink(String teamId) async {
    final team = await session.api.call(
      () => _client.teams.getTeam(teamId: teamId),
    );
    final invite = team.inviteId;
    if (invite == null || invite.isEmpty) return null;
    final base = session.api.baseUrl;
    final root = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$root/signup_user_complete/',
      queryParameters: {'id': invite},
    );
  }
}

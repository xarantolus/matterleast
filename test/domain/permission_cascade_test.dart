import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/permissions.dart';

void main() {
  const granted = {
    'system_user': {'sys'},
    'system_admin': {'admin'},
    'team_user': {'team'},
    'team_admin': {'manage_team'},
    'channel_user': {'chan'},
    'channel_admin': {'manage_team', 'chan_admin'},
  };

  group('system level (haveISystemPermission)', () {
    for (final (roles, permission, expected) in [
      ('system_user', 'sys', true),
      ('system_user system_admin', 'admin', true),
      ('system_user', 'admin', false),
      ('system_user', 'team', false),
      ('', 'sys', false),
      ('unknown_role', 'sys', false),
    ]) {
      test('"$roles" holding $permission is $expected', () {
        expect(
          haveISystemPermission(systemRoles: roles, granted: granted)(
            permission,
          ),
          expected,
        );
      });
    }
  });

  group('team level (haveITeamPermission)', () {
    bool can(String permission, {String system = '', String team = ''}) =>
        haveITeamPermission(
          systemRoles: system,
          teamRoles: team,
          granted: granted,
        )(permission);

    test('the system roles count', () {
      expect(can('admin', system: 'system_admin'), isTrue);
    });
    test('the team roles count', () {
      expect(can('manage_team', team: 'team_user team_admin'), isTrue);
    });
    test('both together grant what either grants', () {
      expect(can('sys', system: 'system_user', team: 'team_user'), isTrue);
      expect(can('team', system: 'system_user', team: 'team_user'), isTrue);
    });
    test('channel roles do not', () {
      expect(can('chan', system: 'system_user', team: 'team_user'), isFalse);
    });
    test('not being a member of the team grants only the system roles', () {
      expect(can('team', system: 'system_user'), isFalse);
    });
  });

  group('channel level (haveIChannelPermission)', () {
    bool can(
      String permission, {
      String system = '',
      String team = '',
      String channel = '',
    }) => haveIChannelPermission(
      systemRoles: system,
      teamRoles: team,
      channelRoles: channel,
      granted: granted,
    )(permission);

    test('system, team and channel roles all count', () {
      expect(can('admin', system: 'system_admin'), isTrue);
      expect(can('manage_team', team: 'team_admin'), isTrue);
      expect(can('chan', channel: 'channel_user'), isTrue);
    });
    test('a direct message has no team roles but keeps the others', () {
      expect(can('chan', system: 'system_user', channel: 'channel_user'), true);
      expect(
        can('team', system: 'system_user', channel: 'channel_user'),
        false,
      );
    });
    test('nothing held means nothing granted', () {
      expect(can('sys'), isFalse);
    });
  });

  group('any team (haveIAnyTeamPermission)', () {
    bool can(String permission, {String system = '', List<String>? teams}) =>
        haveIAnyTeamPermission(
          systemRoles: system,
          teamRoles: teams ?? const [],
          granted: granted,
        )(permission);

    test('one team with the role is enough', () {
      expect(can('manage_team', teams: ['team_user', 'team_admin']), isTrue);
    });
    test('the system roles are enough without any team', () {
      expect(can('sys', system: 'system_user'), isTrue);
    });
    test('no team and no system role grants nothing', () {
      expect(can('manage_team', teams: ['team_user']), isFalse);
    });
  });

  group('rights that were checked at the wrong level', () {
    ChannelRights rights({String team = '', String channel = ''}) =>
        channelRights(
          'O',
          can: haveIChannelPermission(
            systemRoles: 'system_user',
            teamRoles: team,
            channelRoles: channel,
            granted: granted,
          ),
          canInTeam: haveITeamPermission(
            systemRoles: 'system_user',
            teamRoles: team,
            granted: granted,
          ),
        );

    test('restoring a channel is a team right, not a channel one', () {
      expect(rights(team: 'team_admin').unarchive, isTrue);
      expect(rights(channel: 'channel_admin').unarchive, isFalse);
    });
  });
}

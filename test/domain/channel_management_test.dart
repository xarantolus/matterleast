import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/permissions.dart';

Can _canWith(Iterable<String> roles, Grants granted) => haveIChannelPermission(
  systemRoles: roles.join(' '),
  teamRoles: '',
  channelRoles: '',
  granted: granted,
);

ChannelRights _rights(String type, Iterable<String> roles, Grants granted) =>
    channelRights(
      type,
      can: _canWith(roles, granted),
      canInTeam: _canWith(roles, granted),
    );

void main() {
  const granted = {
    'system_user': {'create_team'},
    'team_user': {
      'create_public_channel',
      'join_public_channels',
      'manage_public_channel_properties',
    },
    'channel_user': {'manage_public_channel_members', 'delete_public_channel'},
    'channel_admin': {
      'manage_private_channel_properties',
      'manage_private_channel_members',
    },
  };

  group('a channel member', () {
    final roles = roleNames(['system_user', 'team_user', 'channel_user']);

    test('may edit, archive and add people to a public channel', () {
      final rights = _rights('O', roles, granted);
      expect(rights.edit, isTrue);
      expect(rights.archive, isTrue);
      expect(rights.manageMembers, isTrue);
    });

    test('may do none of it in a private channel without the admin role', () {
      final rights = _rights('P', roles, granted);
      expect(rights, (
        edit: false,
        archive: false,
        manageMembers: false,
        manageRoles: false,
        convert: false,
        unarchive: false,
      ));
    });

    test('gains the private rights as channel admin', () {
      final rights = _rights('P', {...roles, 'channel_admin'}, granted);
      expect(rights.edit, isTrue);
      expect(rights.manageMembers, isTrue);
      expect(rights.archive, isFalse);
    });
  });

  group('making members channel admins', () {
    const roles = {'channel_user'};
    final withRoles = {
      'channel_user': {'manage_public_channel_members', 'manage_channel_roles'},
    };

    test('needs the member permission and the roles permission', () {
      expect(_rights('O', roles, withRoles).manageRoles, isTrue);
      expect(_rights('O', roles, granted).manageRoles, isFalse);
      expect(
        _rights('O', roles, {
          'channel_user': {'manage_channel_roles'},
        }).manageRoles,
        isFalse,
      );
    });

    test('is checked against the private permission in a private channel', () {
      expect(_rights('P', roles, withRoles).manageRoles, isFalse);
    });
  });

  group('inviting to a team', () {
    const granted = {
      'team_admin': {'invite_user', 'add_user_to_team'},
      'team_user': {'add_user_to_team'},
    };
    TeamInviteRights rights(String role, {bool email = true}) =>
        teamInviteRights(
          can: _canWith({role}, granted),
          emailInvitations: email,
        );

    test('email needs the permission and the server setting', () {
      expect(rights('team_admin'), (byEmail: true, byLink: true));
      expect(rights('team_admin', email: false), (
        byEmail: false,
        byLink: true,
      ));
      expect(rights('team_user'), (byEmail: false, byLink: true));
      expect(rights('nobody'), (byEmail: false, byLink: false));
    });
  });

  group('converting a group message', () {
    test('needs a group, a new enough server and the right', () {
      bool can(String type, {bool server = true, bool create = true}) =>
          canConvertGroupMessage(
            type: type,
            serverSupports: server,
            createPrivate: create,
          );
      expect(can('G'), isTrue);
      expect(can('D'), isFalse);
      expect(can('P'), isFalse);
      expect(can('G', server: false), isFalse);
      expect(can('G', create: false), isFalse);
    });
  });

  test('direct and group messages have no channel admin rights', () {
    final roles = {'system_user', 'team_user', 'channel_user', 'channel_admin'};
    for (final type in ['D', 'G']) {
      expect(_rights(type, roles, granted), (
        edit: false,
        archive: false,
        manageMembers: false,
        manageRoles: false,
        convert: false,
        unarchive: false,
      ));
    }
  });

  test('roles the app has not loaded grant nothing', () {
    expect(_canWith({'team_user'}, const {})('create_public_channel'), isFalse);
  });

  test('role strings split into names', () {
    expect(roleNames(['system_user  system_admin', '', 'team_user']), {
      'system_user',
      'system_admin',
      'team_user',
    });
  });

  group('a new channel is linked as', () {
    test('lower case words joined by dashes', () {
      expect(channelSlug('Release Planning 2027'), 'release-planning-2027');
      expect(channelSlug('  Ops & On-call!  '), 'ops-on-call');
    });

    test('nothing when no letters or digits are left', () {
      expect(channelSlug('🚀 !!'), '');
    });

    test('at most 64 characters', () {
      expect(channelSlug('a' * 80).length, 64);
    });
  });

  test('a channel link follows the web app', () {
    expect(
      channelLink('https://chat.example.test/', 'harbor', 'dock-ops'),
      'https://chat.example.test/harbor/channels/dock-ops',
    );
  });

  test('a default setting says what it stands for', () {
    expect(
      effectiveLevel('default', 'mention'),
      'Default (Mentions, direct and group messages)',
    );
    expect(effectiveLevel('none', 'all'), 'Nothing');
  });
}

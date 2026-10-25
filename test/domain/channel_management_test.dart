import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/permissions.dart';

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
      final rights = channelRights('O', roles: roles, granted: granted);
      expect(rights.edit, isTrue);
      expect(rights.archive, isTrue);
      expect(rights.manageMembers, isTrue);
    });

    test('may do none of it in a private channel without the admin role', () {
      final rights = channelRights('P', roles: roles, granted: granted);
      expect(rights, (edit: false, archive: false, manageMembers: false));
    });

    test('gains the private rights as channel admin', () {
      final rights = channelRights(
        'P',
        roles: {...roles, 'channel_admin'},
        granted: granted,
      );
      expect(rights.edit, isTrue);
      expect(rights.manageMembers, isTrue);
      expect(rights.archive, isFalse);
    });
  });

  test('direct and group messages have no channel admin rights', () {
    final roles = {'system_user', 'team_user', 'channel_user', 'channel_admin'};
    for (final type in ['D', 'G']) {
      expect(channelRights(type, roles: roles, granted: granted), (
        edit: false,
        archive: false,
        manageMembers: false,
      ));
    }
  });

  test('roles the app has not loaded grant nothing', () {
    expect(
      hasPermission(
        'create_public_channel',
        roles: {'team_user'},
        granted: const {},
      ),
      isFalse,
    );
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

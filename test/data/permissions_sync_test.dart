import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/permissions.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _role(String name, List<String> permissions) => {
  'id': 'id-$name',
  'name': name,
  'permissions': permissions,
};

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
    server.handle = (r) => switch (r.path) {
      '/api/v4/roles/names' => ok([
        for (final name in (r.json as List).cast<String>())
          if (name == 'channel_admin')
            _role(name, [Permission.deleteOthersPosts])
          else if (name == 'system_admin')
            _role(name, [Permission.editOthersPosts]),
      ]),
      _ => error(404, 'not_found'),
    };
    await session.store.applyMyRoles('system_user');
    await session.store.applyChannelMember(
      api.ChannelMember.fromJson({
        'channel_id': channelId,
        'user_id': meId,
        'roles': 'channel_user',
      }),
    );
    await session.store.applyRoles([
      api.Role.fromJson(
        _role('channel_user', [
          Permission.createPost,
          Permission.editPost,
          Permission.deletePost,
        ]),
      ),
      api.Role.fromJson(_role('system_user', [])),
    ]);
  });

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': {'user_id': meId},
            'seq': 1,
          }),
        ),
      );

  Future<ChannelPermissions> rights() =>
      PermissionViews(session.db).channel(channelId);

  Future<void> settled() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  test('a role that loses create_post closes the channel to posting', () async {
    expect((await rights()).block, isNull);
    await receive('role_updated', {
      'role': jsonEncode(_role('channel_user', [Permission.editPost])),
    });
    expect((await rights()).block, PostingBlock.notAllowed);
  });

  test('a promotion to channel admin lets the user delete others', () async {
    expect((await rights()).deleteOthers, isFalse);
    await receive('channel_member_updated', {
      'channelMember': jsonEncode({
        'channel_id': channelId,
        'user_id': meId,
        'roles': 'channel_user channel_admin',
      }),
    });
    await settled();
    expect((await rights()).deleteOthers, isTrue);
  });

  test('new system roles are stored and their permissions fetched', () async {
    expect((await rights()).editOthers, isFalse);
    await receive('user_role_updated', {
      'user_id': meId,
      'roles': 'system_user system_admin',
    });
    await settled();
    expect(await PermissionViews(session.db).rolesIn(channelId), {
      'system_user',
      'system_admin',
      'channel_user',
    });
    expect((await rights()).editOthers, isTrue);
  });

  test("someone else's role change leaves the user's roles alone", () async {
    await receive('user_role_updated', {
      'user_id': 'someone',
      'roles': 'system_user system_admin',
    });
    await settled();
    expect(await PermissionViews(session.db).rolesIn(channelId), {
      'system_user',
      'channel_user',
    });
  });
}

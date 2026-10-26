import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/autocomplete.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ComposerActions actions;

  Map<String, Object?> person(String id, String username) => {
    'id': id,
    'username': username,
    'first_name': '',
    'last_name': '',
  };

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
    actions = ComposerActions(session);
    await session.store.applyUsers([
      api.User.fromJson(person('u1', 'mabel')),
      api.User.fromJson(person('u2', 'otto')),
    ]);
  });

  tearDown(() async {
    await actions.dispose();
    await closeTestSession(session);
    await server.close();
  });

  Future<List<List<String>>> suggest(String text, {String rootId = ''}) async =>
      [
        await for (final list in actions.suggestions(
          channelId: channelId,
          teamId: teamId,
          rootId: rootId,
          text: text,
          cursor: text.length,
        ))
          [for (final s in list) s.replacement],
      ];

  test('people known here show first, then the server adds its own', () async {
    server.handle = (r) => r.path == '/api/v4/users/autocomplete'
        ? ok({
            'users': [person('u1', 'mabel'), person('u3', 'marta')],
            'out_of_channel': [person('u4', 'max')],
          })
        : error(404, 'not_found');
    final lists = await suggest('hi @ma');
    expect(lists, [
      ['@mabel'],
      ['@mabel', '@marta', '@max'],
    ]);
    final asked = server.seen.single.raw.uri.queryParameters;
    expect(asked['name'], 'ma');
    expect(asked['in_channel'], channelId);
    expect(asked['in_team'], teamId);
  });

  test('a failing server leaves the local suggestions', () async {
    server.handle = (r) => error(500, 'boom');
    expect(await suggest('@ot'), [
      ['@otto'],
    ]);
  });

  test('identical lookups in flight are asked once', () async {
    final answer = Completer<Reply>();
    server.handle = (r) => answer.future;
    final first = suggest('@ma');
    final second = suggest('@ma');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    answer.complete(ok({'users': <Object?>[], 'out_of_channel': <Object?>[]}));
    await Future.wait([first, second]);
    expect(server.seen.length, 1);
  });

  test('channels come from the database and the server', () async {
    server.handle = (r) =>
        r.path == '/api/v4/teams/$teamId/channels/autocomplete'
        ? ok([
            {
              'id': 'ch2',
              'team_id': teamId,
              'type': 'O',
              'name': 'boatyard',
              'display_name': 'Boatyard',
            },
          ])
        : error(404, 'not_found');
    final lists = await suggest('~boa');
    expect(lists, [
      ['~boats'],
      ['~boats', '~boatyard'],
    ]);
  });

  test('emoji: system ones at once, custom ones from the server', () async {
    await session.store.applyConfig('client_config', {
      'EnableCustomEmoji': 'true',
    });
    server.handle = (r) => r.path == '/api/v4/emoji/autocomplete'
        ? ok([
            {'id': 'e1', 'name': 'thumbsup_parrot', 'creator_id': 'u2'},
          ])
        : error(404, 'not_found');
    final lists = await suggest('ok :thumbsu');
    expect(lists.first, contains('👍'));
    expect(lists.last, contains(':thumbsup_parrot:'));
  });

  test('emoji used in a sent message are suggested first next time', () async {
    await actions.send(channelId, message: 'all good :sunflower:');
    final lists = await suggest(':su');
    expect(lists.first.first, '🌻');
  });

  test('commands are listed by trigger and fetched once a minute', () async {
    server.handle = (r) =>
        r.path == '/api/v4/teams/$teamId/commands/autocomplete'
        ? ok([
            {'trigger': 'shout', 'auto_complete_hint': '[text]'},
            {'trigger': 'lunch'},
          ])
        : error(404, 'not_found');
    expect((await suggest('/sh')).last, ['/shout']);
    expect((await suggest('/')).last, ['/lunch', '/shout']);
    expect(server.seen.length, 1);
  });

  test('command arguments come from the server', () async {
    server.handle = (r) =>
        r.path == '/api/v4/teams/$teamId/commands/autocomplete_suggestions'
        ? ok([
            {'Complete': 'lunch today', 'Suggestion': 'today', 'Hint': ''},
          ])
        : error(404, 'not_found');
    final lists = await suggest('/lunch to', rootId: 'root1');
    expect(lists.last, ['/lunch today']);
    final asked = server.seen.single.raw.uri.queryParameters;
    expect(asked['user_input'], '/lunch to');
    expect(asked['root_id'], 'root1');
    expect(asked['channel_id'], channelId);
  });

  test('outside a trigger there is nothing to suggest', () async {
    expect(await suggest('plain words'), [<String>[]]);
    expect(server.seen, isEmpty);
  });

  test('suggestion kinds carry what the list shows', () async {
    server.handle = (r) => error(500, 'down');
    final list = await actions
        .suggestions(
          channelId: channelId,
          teamId: teamId,
          text: '@mab',
          cursor: 4,
        )
        .first;
    expect(list.single, isA<UserSuggestion>());
  });

  group('groups', () {
    Future<void> groupsAllowed({required bool licensed}) async {
      await session.store.applyConfig(ConfigKeys.license, {
        'IsLicensed': '$licensed',
      });
      await session.store.applyMyRoles('system_user');
      await session.store.applyRoles([
        api.Role.fromJson({
          'name': 'system_user',
          'permissions': ['use_group_mentions'],
        }),
      ]);
    }

    Reply answer(SeenRequest r) => switch (r.path) {
      '/api/v4/users/autocomplete' => ok({
        'users': [person('u1', 'mabel')],
        'out_of_channel': <Object?>[],
      }),
      '/api/v4/groups' => ok([
        {'id': 'g1', 'name': 'makers', 'display_name': 'Makers'},
      ]),
      _ => error(404, 'not_found'),
    };

    test('a licensed server suggests groups the user may mention', () async {
      await groupsAllowed(licensed: true);
      server.handle = answer;
      final lists = await suggest('@ma');
      expect(lists.last, ['@mabel', '@makers']);
      final asked = server.seen
          .firstWhere((r) => r.path == '/api/v4/groups')
          .raw
          .uri
          .queryParameters;
      expect(asked['q'], 'ma');
      expect(asked['filter_allow_reference'], 'true');
    });

    test('without a licence or the permission no group is asked', () async {
      await groupsAllowed(licensed: false);
      server.handle = answer;
      expect((await suggest('@ma')).last, ['@mabel']);
      await groupsAllowed(licensed: true);
      await session.store.applyRoles([
        api.Role.fromJson({'name': 'system_user', 'permissions': <String>[]}),
      ]);
      expect((await suggest('@ma')).last, ['@mabel']);
      expect(server.paths, isNot(contains('/api/v4/groups')));
    });

    test('a server without groups turns them off quietly', () async {
      await groupsAllowed(licensed: true);
      server.handle = (r) => r.path == '/api/v4/groups'
          ? error(501, 'api.ldap_groups.license_error')
          : answer(r);
      expect((await suggest('@ma')).last, ['@mabel']);
      expect((await session.db.features()).groupMentions, isFalse);
      await suggest('@mab');
      expect(server.paths.where((p) => p == '/api/v4/groups'), hasLength(1));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/data/actions/profile_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/search_views.dart';
import 'package:matterleast/domain/user_profile.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Iterable<String> asked(String path) =>
      server.seen.where((r) => r.path == path).map((r) => r.path);

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': <String, Object?>{},
            'seq': 1,
          }),
        ),
      );

  group('plugins', () {
    const pluginsPath = '/api/v4/plugins/webapp';

    test('the enabled plugins are known, and a plugin event refreshes '
        'them', () async {
      var listed = [
        {'id': 'com.example.helper', 'version': '1.2.0'},
      ];
      server.handle = (r) =>
          r.path == pluginsPath ? ok(listed) : error(404, 'not_found');
      await session.store.applyConfig('client_config', {
        'PluginsEnabled': 'true',
      });
      await session.connection.entry.refreshPlugins();
      expect(
        (await session.db.features()).hasPlugin(
          'com.example.helper',
          minVersion: (1, 2, 0),
        ),
        isTrue,
      );

      listed = [];
      await receive('plugin_disabled', {});
      final after = await session.db
          .watchFeatures()
          .firstWhere((f) => f.plugins.isEmpty)
          .timeout(const Duration(seconds: 5));
      expect(after.hasPlugin('com.example.helper'), isFalse);
    });

    test('a server without plugins is not asked, and one that answers 501 '
        'just has none', () async {
      server.handle = (r) => error(501, 'app.plugin.disabled.app_error');
      await session.store.applyConfig('client_config', {
        'PluginsEnabled': 'false',
      });
      await session.connection.entry.refreshPlugins();
      expect(asked(pluginsPath), isEmpty);

      await session.store.applyConfig('client_config', {
        'PluginsEnabled': 'true',
      });
      await session.connection.entry.refreshPlugins();
      expect(asked(pluginsPath), hasLength(1));
      expect((await session.db.features()).plugins, isEmpty);
    });
  });

  test('a config change reaches everyone watching the features', () async {
    await session.store.applyConfig('client_config', {'MaxPostSize': '5000'});
    final sizes = session.db.watchFeatures().map((f) => f.maxPostSize);
    final seen = <int>[];
    final sub = sizes.listen(seen.add);
    await pumpEventQueue();
    await receive('config_changed', {
      'config': {'MaxPostSize': '6000'},
    });
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [5000, 6000]);
  });

  test('custom status the server lacks turns off until the server is opened '
      'again', () async {
    await session.store.applyConfig('client_config', {
      'EnableCustomUserStatuses': 'true',
    });
    server.handle = (r) => error(501, 'api.custom_status.disabled');
    await expectLater(
      ProfileActions(session)
          .setCustomStatus(const CustomStatus(emoji: 'coffee', text: 'Break')),
      throwsA(isA<ServerError>()),
    );
    expect((await session.db.features()).customStatus, isFalse);

    await session.store.clearTurnedOff();
    expect((await session.db.features()).customStatus, isTrue);
  });

  test('a server without file search finds no files, without an error and '
      'without asking again', () async {
    server.handle = (r) => error(501, 'api.file.search.disabled');
    final search = MessageSearch(
      session,
      SearchViews(session.db, serverUrl: '${server.url}'),
    );
    expect(await search.files(teamId, 'report'), isEmpty);
    expect(await search.files(teamId, 'invoice'), isEmpty);
    expect(server.seen, hasLength(1));
  });

  test('command suggestions stop asking once the server says it has '
      'none', () async {
    server.handle = (r) => error(404, 'api.context.404.app_error');
    final actions = ComposerActions(session);
    Future<void> type(String text) => actions
        .suggestions(
          channelId: channelId,
          teamId: teamId,
          rootId: '',
          text: text,
          cursor: text.length,
        )
        .drain<void>();
    await type('/sh');
    final asks = server.seen.length;
    expect(asks, greaterThan(0));
    await type('/lu');
    await type('/shout lou');
    expect(server.seen, hasLength(asks));
    await actions.dispose();
  });

  test(
    'custom emoji the server switched off are no longer looked up',
    () async {
      await session.store.applyConfig('client_config', {
        'EnableCustomEmoji': 'true',
      });
      server.handle = (r) => error(501, 'api.emoji.disabled.app_error');
      session.emoji.want(['partyblob']);
      await session.emoji.settled;
      expect((await session.db.features()).customEmoji, isFalse);
      final asks = server.seen.length;
      session.emoji.want(['shipit']);
      await session.emoji.settled;
      expect(server.seen, hasLength(asks));
    },
  );
}

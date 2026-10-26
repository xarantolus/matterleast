import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/preference_keys.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ComposerActions composer;

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
    composer = session.composer;
  });

  tearDown(() async {
    await composer.dispose();
    await closeTestSession(session);
    await server.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 700));

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

  Future<void> config(
    Map<String, String> values, {
    bool licensed = false,
  }) async {
    await session.store.applyConfig(ConfigKeys.clientConfig, values);
    await session.store.applyConfig(ConfigKeys.license, {
      'IsLicensed': '$licensed',
      'SkuShortName': licensed ? 'advanced' : '',
    });
  }

  Iterable<SeenRequest> requests(String method, String path) =>
      server.seen.where((r) => r.method == method && r.path == path);

  Future<List<String>> draftMessages() async => [
    for (final d in await session.db.select(session.db.drafts).get()) d.message,
  ];

  group('synced drafts', () {
    final serverAt = DateTime.utc(2026, 10, 26, 9).millisecondsSinceEpoch;
    Map<String, Object?> serverDraft(
      String message,
      int at, {
      String root = '',
    }) => {
      'channel_id': channelId,
      'root_id': root,
      'user_id': meId,
      'message': message,
      'create_at': at,
      'update_at': at,
    };

    setUp(() async {
      server.handle = (r) => switch ((r.method, r.path)) {
        ('POST', '/api/v4/drafts') => ok({
          ...r.body,
          'update_at': DateTime.now().millisecondsSinceEpoch,
        }),
        ('DELETE', _) => ok({'status': 'OK'}),
        _ => error(404, 'not_found'),
      };
      await config({'AllowSyncedDrafts': 'true'});
    });

    test('a saved draft reaches the server, and clearing it deletes it '
        'there', () async {
      composer.saveDraft(
        const Draft(channelId: channelId, message: 'half a thought'),
      );
      await settle();
      final sent = requests('POST', '/api/v4/drafts').single;
      expect(sent.body['message'], 'half a thought');
      expect(sent.body['channel_id'], channelId);

      await composer.clearDraft(channelId);
      await settle();
      expect(
        requests('DELETE', '/api/v4/users/me/channels/$channelId/drafts'),
        hasLength(1),
      );
    });

    test(
      'nothing goes to the server when the user turned syncing off',
      () async {
        await session.store.applyPreferences([
          api.Preference(
            userId: meId,
            category: Prefs.syncDrafts.$1,
            name: Prefs.syncDrafts.$2,
            value: 'false',
          ),
        ]);
        composer.saveDraft(const Draft(channelId: channelId, message: 'local'));
        await settle();
        expect(server.seen, isEmpty);
        expect(await draftMessages(), ['local']);
      },
    );

    test('nothing goes to the server when it does not allow syncing', () async {
      await config({'AllowSyncedDrafts': 'false'});
      composer.saveDraft(const Draft(channelId: channelId, message: 'local'));
      await settle();
      expect(server.seen, isEmpty);
    });

    test('a draft written on another device appears, and one deleted there '
        'goes', () async {
      server.handle = (r) => r.path == '/api/v4/users/me/teams/$teamId/drafts'
          ? ok([serverDraft('from the laptop', serverAt)])
          : error(404, 'not_found');
      await session.connection.drafts.pull(teamId);
      expect(await draftMessages(), ['from the laptop']);

      server.handle = (r) => ok(<Object?>[]);
      await session.connection.drafts.pull(teamId);
      expect(await draftMessages(), isEmpty);
    });

    test('an edit here newer than the server copy wins and is sent', () async {
      composer.saveDraft(const Draft(channelId: channelId, message: 'newer'));
      await composer.flushDrafts();
      server.handle = (r) => switch ((r.method, r.path)) {
        ('GET', _) => ok([serverDraft('older', serverAt)]),
        ('POST', '/api/v4/drafts') => ok({
          ...r.body,
          'update_at': serverAt + 1,
        }),
        _ => error(404, 'not_found'),
      };
      server.seen.clear();
      await session.connection.drafts.pull(teamId);
      await settle();
      expect(await draftMessages(), ['newer']);
      expect(requests('POST', '/api/v4/drafts').last.body['message'], 'newer');
    });

    test(
      'draft events replace an older draft and delete a synced one',
      () async {
        await receive('draft_updated', {
          'draft': jsonEncode(serverDraft('typed elsewhere', serverAt)),
        });
        expect(await draftMessages(), ['typed elsewhere']);

        await receive('draft_deleted', {
          'draft': jsonEncode(serverDraft('', serverAt)),
        });
        expect(await draftMessages(), isEmpty);
      },
    );

    test(
      'a server without synced drafts turns syncing off for the session',
      () async {
        server.handle = (r) => error(501, 'api.drafts.disabled');
        composer.saveDraft(const Draft(channelId: channelId, message: 'x'));
        await settle();
        expect((await session.db.features()).syncedDrafts, isFalse);
      },
    );
  });

  group('scheduled posts', () {
    final at = DateTime.utc(2026, 10, 27, 8);
    Map<String, Object?> scheduled(String id, {String? errorCode}) => {
      'id': id,
      'channel_id': channelId,
      'root_id': '',
      'user_id': meId,
      'message': 'Standup at nine',
      'scheduled_at': at.millisecondsSinceEpoch,
      'create_at': at.millisecondsSinceEpoch - 1000,
      'update_at': at.millisecondsSinceEpoch - 1000,
      'error_code': ?errorCode,
    };

    Future<List<String>> stored() async => [
      for (final s in await session.db.select(session.db.scheduledPosts).get())
        '${s.id}:${s.errorCode ?? ''}',
    ];

    test('they are off without the setting or without a licence', () async {
      await config({'ScheduledPosts': 'true'});
      expect((await session.db.features()).scheduledPosts, isFalse);
      await config({'ScheduledPosts': 'false'}, licensed: true);
      expect((await session.db.features()).scheduledPosts, isFalse);
      await config({'ScheduledPosts': 'true'}, licensed: true);
      expect((await session.db.features()).scheduledPosts, isTrue);
    });

    test(
      'scheduling sends it to the server, lists it and clears the draft',
      () async {
        await config({'ScheduledPosts': 'true'}, licensed: true);
        server.handle = (r) => r.path == '/api/v4/posts/schedule'
            ? ok({...r.body, 'id': 'sp1'})
            : error(404, 'not_found');
        composer.saveDraft(
          const Draft(channelId: channelId, message: 'Standup at nine'),
        );
        await composer.flushDrafts();

        await composer.schedule(channelId, message: 'Standup at nine', at: at);

        final sent = requests('POST', '/api/v4/posts/schedule').single;
        expect(sent.body['scheduled_at'], at.millisecondsSinceEpoch);
        expect(sent.body['message'], 'Standup at nine');
        expect(await stored(), ['sp1:']);
        expect(await draftMessages(), isEmpty);
      },
    );

    test('the server list replaces what is stored, failed ones keep their '
        'reason', () async {
      await config({'ScheduledPosts': 'true'}, licensed: true);
      server.handle = (r) => ok({
        teamId: [scheduled('sp1')],
        'directChannels': [scheduled('sp2', errorCode: 'user_deleted')],
      });
      await session.connection.scheduled.fetch(teamId);
      expect(
        requests(
          'GET',
          '/api/v4/posts/scheduled/team/$teamId',
        ).single.raw.uri.queryParameters['includeDirectChannels'],
        'true',
      );
      expect(await stored(), unorderedEquals(['sp1:', 'sp2:user_deleted']));

      server.handle = (r) => ok({teamId: <Object?>[]});
      await session.connection.scheduled.fetch(teamId);
      expect(await stored(), isEmpty);
    });

    test('events add, update and remove them', () async {
      await receive('scheduled_post_created', {
        'scheduledPost': jsonEncode(scheduled('sp1')),
      });
      expect(await stored(), ['sp1:']);
      await receive('scheduled_post_updated', {
        'scheduledPost': jsonEncode(scheduled('sp1', errorCode: 'unknown')),
      });
      expect(await stored(), ['sp1:unknown']);
      await receive('scheduled_post_deleted', {
        'scheduledPost': jsonEncode(scheduled('sp1')),
      });
      expect(await stored(), isEmpty);
    });

    test('rescheduling sends the whole post back with the new time', () async {
      await config({'ScheduledPosts': 'true'}, licensed: true);
      await receive('scheduled_post_created', {
        'scheduledPost': jsonEncode(scheduled('sp1', errorCode: 'unknown')),
      });
      final later = at.add(const Duration(days: 1));
      server.handle = (r) => ok(r.body);
      await session.connection.scheduled.reschedule('sp1', later);
      final put = requests('PUT', '/api/v4/posts/schedule/sp1').single;
      expect(put.body['scheduled_at'], later.millisecondsSinceEpoch);
      expect(put.body['message'], 'Standup at nine');
      expect(await stored(), ['sp1:']);
    });

    test('a server that says it needs a licence turns scheduling off and '
        'the error says so', () async {
      await config({'ScheduledPosts': 'true'}, licensed: true);
      server.handle = (r) => error(400, 'api.scheduled_posts.license_error');
      await expectLater(
        composer.schedule(channelId, message: 'x', at: at),
        throwsA(isA<ServerError>()),
      );
      expect((await session.db.features()).scheduledPosts, isFalse);
    });
  });

  group('burn on read', () {
    final created = DateTime.utc(2026, 10, 26, 9).millisecondsSinceEpoch;
    Map<String, Object?> post({
      String userId = 'someone',
      String message = '',
      int? expireAt,
      int? maxExpireAt,
    }) => {
      'id': 'bor1',
      'channel_id': channelId,
      'user_id': userId,
      'type': 'burn_on_read',
      'create_at': created,
      'message': message,
      'props': {'expire_at': ?maxExpireAt},
      'metadata': {'expire_at': ?expireAt},
    };

    Future<String?> stored() async =>
        (await session.store.post('bor1'))?.message;

    test('revealing stores the content and its burn time', () async {
      await session.store.applyEdit(api.Post.fromJson(post()));
      final burns = DateTime.now().add(const Duration(minutes: 10));
      server.handle = (r) => r.path == '/api/v4/posts/bor1/reveal'
          ? ok(
              post(
                message: 'the secret',
                expireAt: burns.millisecondsSinceEpoch,
              ),
            )
          : error(404, 'not_found');
      await session.posts.reveal('bor1');
      expect(await stored(), 'the secret');
      expect(
        jsonDecode((await session.store.post('bor1'))!.metadataJson!),
        containsPair('expire_at', burns.millisecondsSinceEpoch),
      );
    });

    test('a message that burned before it was opened goes', () async {
      await session.store.applyEdit(api.Post.fromJson(post()));
      server.handle = (r) =>
          error(400, 'app.post.burn_on_read.expired.app_error');
      await expectLater(session.posts.reveal('bor1'), throwsA(anything));
      expect(await session.store.post('bor1'), isNull);
    });

    test('burning now removes it from the cache', () async {
      await session.store.applyEdit(
        api.Post.fromJson(post(userId: meId, message: 'mine')),
      );
      server.handle = (r) =>
          r.method == 'DELETE' && r.path == '/api/v4/posts/bor1/burn'
          ? ok({'status': 'OK'})
          : error(404, 'not_found');
      await session.posts.burnNow('bor1');
      expect(await session.store.post('bor1'), isNull);
    });

    test('burned and all-revealed events', () async {
      await session.store.applyEdit(
        api.Post.fromJson(post(userId: meId, message: 'mine')),
      );
      final at = DateTime.utc(2026, 10, 26, 10);
      await receive('burn_on_read_all_revealed', {
        'post_id': 'bor1',
        'sender_expire_at': at.millisecondsSinceEpoch,
      });
      expect(
        jsonDecode((await session.store.post('bor1'))!.metadataJson!),
        containsPair('expire_at', at.millisecondsSinceEpoch),
      );

      await receive('post_burned', {'post_id': 'bor1'});
      expect(await session.store.post('bor1'), isNull);
    });

    test('a burned event never removes an ordinary message', () async {
      await receive('post_burned', {'post_id': 'old1'});
      expect(await session.store.post('old1'), isNotNull);
    });

    test(
      'expired messages are removed from the cache, live ones stay',
      () async {
        final now = DateTime.utc(2026, 10, 26, 12);
        await session.store.applyEdit(
          api.Post.fromJson(
            post(
              message: 'read',
              expireAt: now
                  .subtract(const Duration(minutes: 1))
                  .millisecondsSinceEpoch,
            ),
          ),
        );
        await session.store.applyEdit(
          api.Post.fromJson({
            ...post(message: 'unopened'),
            'id': 'bor2',
            'props': {
              'expire_at': now
                  .add(const Duration(days: 1))
                  .millisecondsSinceEpoch,
            },
          }),
        );
        await session.store.removeBurnedPosts(now);
        expect(await session.store.post('bor1'), isNull);
        expect(await session.store.post('bor2'), isNotNull);
      },
    );

    test(
      'a message sent to burn after reading goes out with its type',
      () async {
        server.handle = (r) => r.path == '/api/v4/posts'
            ? ok({...r.body, 'id': 'p1', 'user_id': meId, 'create_at': created})
            : error(404, 'not_found');
        await composer.send(channelId, message: 'secret', burnOnRead: true);
        await session.outbox.start();
        await settle();
        expect(
          requests('POST', '/api/v4/posts').single.body['type'],
          'burn_on_read',
        );
      },
    );

    test(
      'sending is offered only with the setting and an advanced licence',
      () async {
        await config({'EnableBurnOnRead': 'true'});
        expect((await session.db.features()).burnOnRead, isFalse);
        await config({
          'EnableBurnOnRead': 'true',
          'BurnOnReadDurationSeconds': '300',
        }, licensed: true);
        final features = await session.db.features();
        expect(features.burnOnRead, isTrue);
        expect(features.burnOnReadDuration, const Duration(minutes: 5));
      },
    );
  });
}

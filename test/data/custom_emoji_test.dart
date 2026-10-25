import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/emoji/custom_emoji.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';

import '../support/fake_server.dart';

Map<String, Object?> emojiJson(String name, {String? id}) => {
  'id': id ?? 'id-$name',
  'name': name,
  'creator_id': 'u1',
  'create_at': 1000,
  'update_at': 1000,
  'delete_at': 0,
};

void main() {
  late FakeServer server;
  late ServerDatabase db;
  late ServerStore store;
  late ServerApi http;
  late CustomEmojiResolver resolver;
  var now = DateTime.utc(2026, 10, 25, 12);

  /// Names the fake server has as custom emoji.
  var onServer = <String>{};

  setUp(() async {
    server = await FakeServer.start();
    db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
    store = ServerStore(db);
    http = ServerApi(baseUrl: server.url, token: () => 't');
    now = DateTime.utc(2026, 10, 25, 12);
    onServer = {'partyblob', 'shipit'};
    resolver = CustomEmojiResolver(
      server: http,
      store: store,
      clock: () => now,
    );
    await store.applyConfig('client_config', {'EnableCustomEmoji': 'true'});
    server.handle = (r) {
      if (r.path == '/api/v4/emoji/names') {
        final names = (r.json! as List).cast<String>();
        return ok([
          for (final n in names)
            if (onServer.contains(n)) emojiJson(n),
        ]);
      }
      return error(404, 'not_found');
    };
  });

  tearDown(() async {
    resolver.close();
    http.close();
    await db.close();
    await server.close();
  });

  Future<Map<String, String>> stored() async => {
    for (final row in await db.select(db.customEmoji).get()) row.name: row.id,
  };

  List<List<String>> batches() => [
    for (final r in server.seen)
      if (r.path == '/api/v4/emoji/names') (r.json! as List).cast<String>(),
  ];

  test('unknown names are asked for together and stored', () async {
    await store.applyCustomEmoji([api.Emoji.fromJson(emojiJson('known'))]);
    resolver.want(['partyblob', 'smile', 'known']);
    resolver.want(['shipit', 'partyblob', 'not a name']);
    await resolver.settled;
    expect(batches(), [
      ['partyblob', 'shipit'],
    ], reason: 'unicode, stored and invalid names are not asked for');
    expect(await stored(), {
      'known': 'id-known',
      'partyblob': 'id-partyblob',
      'shipit': 'id-shipit',
    });
  });

  test('many names go in batches of 200', () async {
    resolver.want([for (var i = 0; i < 250; i++) 'custom_$i']);
    await resolver.settled;
    expect([for (final b in batches()) b.length], [200, 50]);
  });

  test('names the server does not know wait an hour', () async {
    resolver.want(['nope']);
    await resolver.settled;
    resolver.want(['nope']);
    await resolver.settled;
    expect(batches(), [
      ['nope'],
    ]);

    now = now.add(const Duration(minutes: 61));
    onServer.add('nope');
    resolver.want(['nope']);
    await resolver.settled;
    expect(batches().length, 2);
    expect((await stored()).keys, contains('nope'));
  });

  test('older servers are asked one name at a time', () async {
    server.handle = (r) => switch (r.path) {
      '/api/v4/emoji/name/partyblob' => ok(emojiJson('partyblob')),
      _ => error(404, 'api.context.404.app_error'),
    };
    resolver.want(['partyblob', 'nope']);
    await resolver.settled;
    expect(server.paths, [
      '/api/v4/emoji/names',
      '/api/v4/emoji/name/partyblob',
      '/api/v4/emoji/name/nope',
    ]);
    expect((await stored()).keys, ['partyblob']);

    server.seen.clear();
    resolver.want(['shipit']);
    await resolver.settled;
    expect(server.paths, ['/api/v4/emoji/name/shipit']);
  });

  test('nothing is asked when custom emoji are off', () async {
    await store.applyConfig('client_config', {'EnableCustomEmoji': 'false'});
    resolver.want(['partyblob']);
    await resolver.settled;
    expect(server.seen, isEmpty);
  });

  test('a failed lookup is tried again a minute later', () async {
    server.handle = (_) => error(500, 'boom');
    resolver.want(['partyblob']);
    await resolver.settled;
    resolver.want(['partyblob']);
    await resolver.settled;
    expect(server.seen.length, 1);
    now = now.add(const Duration(minutes: 2));
    resolver.want(['partyblob']);
    await resolver.settled;
    expect(server.seen.length, 2);
  });

  test('the name map follows the table', () async {
    final seen = <Map<String, String>>[];
    final subscription = watchCustomEmoji(store).listen(seen.add);
    Future<void> until(int count) async {
      while (seen.length < count) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    await until(1);
    expect(seen.single, isEmpty);
    await store.applyCustomEmoji([api.Emoji.fromJson(emojiJson('partyblob'))]);
    await until(2);
    expect(seen.last, {'partyblob': 'id-partyblob'});
    await subscription.cancel();
  });

  test('emoji in post metadata are stored with the posts', () async {
    await store.applyLivePost(
      api.Post.fromJson({
        'id': 'p1',
        'channel_id': 'c1',
        'user_id': 'u1',
        'create_at': 5000,
        'message': ':partyblob:',
        'metadata': {
          'emojis': [emojiJson('partyblob')],
        },
      }),
      fromSelf: false,
      mentionsMe: false,
    );
    expect(await stored(), {'partyblob': 'id-partyblob'});
  });

  test('a re-created emoji replaces the old one of the same name', () async {
    await store.applyCustomEmoji([
      api.Emoji.fromJson(emojiJson('partyblob', id: 'old')),
    ]);
    await store.applyCustomEmoji([
      api.Emoji.fromJson(emojiJson('partyblob', id: 'new')),
    ]);
    expect(await stored(), {'partyblob': 'new'});
  });

  test('emoji_added decodes the emoji sent as a JSON string', () {
    final event = decodeEvent(
      SocketFrame.fromJson({
        'event': 'emoji_added',
        'data': {'emoji': jsonEncode(emojiJson('shipit'))},
        'broadcast': {'omit_users': null, 'user_id': '', 'channel_id': ''},
        'seq': 4,
      }),
    );
    expect(event, isA<EmojiAddedEvent>());
    expect((event as EmojiAddedEvent).emoji!.name, 'shipit');
  });
}

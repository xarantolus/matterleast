import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';

import '../support/memory_database.dart';

Map<String, Object?> plain(String id, int at) => {
  'id': id,
  'channel_id': 'c1',
  'user_id': 'u2',
  'root_id': '',
  'create_at': at,
  'message': 'hello $id',
};

Map<String, Object?> hostile(String id, int at) => {
  ...plain(id, at),
  'type': 'custom_unknown_kind',
  'has_reactions': 'true',
  'file_ids': null,
  'props': {
    'nested': [
      [1, 2],
      [
        {'a': null},
      ],
    ],
    'attachments': 'not a list',
  },
  'metadata': {
    'priority': null,
    'embeds': [
      {'type': 'hologram', 'url': 'https://example.invalid', 'data': null},
      {'type': 'opengraph', 'data': null},
      {'type': 'message_attachment', 'data': 'oops'},
      {'type': 7, 'url': 42},
      {
        'type': 'permalink',
        'data': {'post_id': 'p1'},
      },
      null,
    ],
    'files': [
      {
        'id': 'f1',
        'post_id': id,
        'name': 'clip.mp4',
        'mime_type': 'video/mp4',
        'width': '1920',
        'height': 1080.0,
        'size': '1048576',
        'mini_preview': null,
        'has_preview_image': 'true',
        'create_at': '1700000000000',
      },
    ],
    'images': <Object?>[],
    'emojis': {'not': 'a list'},
    'reactions': 'none',
  },
};

void main() {
  late ServerDatabase db;
  late ServerStore store;

  setUp(() {
    db = memoryDatabase();
    store = ServerStore(db);
  });
  tearDown(() => db.close());

  Future<List<String>> storedIds() async =>
      [for (final r in await db.select(db.posts).get()) r.id]..sort();

  test('a page with one hostile post stores every post', () async {
    final page = api.PostList.fromJson({
      'order': ['p3', 'p2', 'p1'],
      'posts': {
        'p1': plain('p1', 1000),
        'p2': hostile('p2', 2000),
        'p3': plain('p3', 3000),
      },
    });
    await store.applyChannelPage(
      channelId: 'c1',
      page: page,
      kind: PageKind.page,
    );
    expect(await storedIds(), ['p1', 'p2', 'p3']);
    final row = await (db.select(
      db.posts,
    )..where((p) => p.id.equals('p2'))).getSingle();
    expect(row.message, 'hello p2');
    expect(row.fileCount, 1);
    final files = await db.select(db.files).get();
    expect(files.single.width, 1920);
    expect(files.single.size, 1048576);
  });

  test('a post without metadata or props stores', () async {
    final page = api.PostList.fromJson({
      'order': ['p1'],
      'posts': {
        'p1': {...plain('p1', 1000), 'metadata': null, 'props': null},
      },
    });
    await store.applyChannelPage(
      channelId: 'c1',
      page: page,
      kind: PageKind.page,
    );
    expect(await storedIds(), ['p1']);
  });

  test('a posted event with a hostile post is stored', () async {
    final event = PostedEvent.fromJson({
      'post': jsonEncode(hostile('p9', 9000)),
      'mentions': '[]',
    });
    await store.applyLivePost(event.post!, fromSelf: true, mentionsMe: false);
    expect(await storedIds(), ['p9']);
  });
}

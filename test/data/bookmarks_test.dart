import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/extras_views.dart';
import 'package:matterleast/domain/bookmarks.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _link(
  String id,
  String name, {
  int sortOrder = 0,
  int at = 1000,
  int? deletedAt,
}) => {
  'id': id,
  'channel_id': channelId,
  'display_name': name,
  'type': 'link',
  'link_url': 'https://example.com/$id',
  'sort_order': sortOrder,
  'create_at': at,
  'update_at': at,
  'delete_at': ?deletedAt,
};

void main() {
  late FakeServer server;
  late ServerSession session;
  var stored = <Map<String, Object?>>[];

  setUp(() async {
    server = await FakeServer.start();
    stored = [];
    server.handle = (r) => switch ((r.method, r.path)) {
      ('GET', '/api/v4/channels/$channelId/bookmarks') => ok(stored),
      _ => error(404, 'not_found'),
    };
    session = await testSession(server);
    await session.store.applyConfig('client_config', {'Version': '12.0.1'});
    await session.store.applyConfig('license', {'IsLicensed': 'true'});
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Future<List<String>> bar() async => [
    for (final b in await BookmarkViews(session.db).bookmarks(channelId).first)
      b.displayName,
  ];

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': event,
            'data': data,
            'broadcast': {'channel_id': channelId},
            'seq': 1,
          }),
        ),
      );

  test('shows the channel bookmarks in the server order', () async {
    stored = [_link('b2', 'Roadmap', sortOrder: 1), _link('b1', 'Handbook')];
    await session.bookmarks.refresh(channelId);
    expect(await bar(), ['Handbook', 'Roadmap']);
  });

  test('asks only for changes after the first fetch and drops deleted '
      'ones', () async {
    stored = [_link('b1', 'Handbook', at: 1000)];
    await session.bookmarks.refresh(channelId);
    stored = [_link('b1', 'Handbook', at: 1000, deletedAt: 2000)];
    await session.bookmarks.refresh(channelId);
    final asks = [
      for (final r in server.seen)
        if (r.path.endsWith('/bookmarks'))
          r.raw.uri.queryParameters['bookmarks_since'],
    ];
    expect(asks, [null, '1000']);
    expect(await bar(), isEmpty);
  });

  test('a file bookmark carries its file for opening', () async {
    stored = [
      {
        'id': 'b1',
        'channel_id': channelId,
        'display_name': 'Checklist',
        'type': 'file',
        'file_id': 'f1',
        'file': {
          'id': 'f1',
          'name': 'checklist.pdf',
          'extension': 'pdf',
          'size': 2048,
        },
      },
    ];
    await session.bookmarks.refresh(channelId);
    final b = (await BookmarkViews(
      session.db,
    ).bookmarks(channelId).first).single;
    expect(b.isFile, isTrue);
    expect(b.file?.name, 'checklist.pdf');
    expect(b.file?.extension, 'pdf');
  });

  test('without a licence nothing is asked and the bar stays empty', () async {
    await session.store.applyConfig('license', {'IsLicensed': 'false'});
    stored = [_link('b1', 'Handbook')];
    await session.bookmarks.refresh(channelId);
    expect(server.paths.where((p) => p.contains('bookmarks')), isEmpty);
    expect(await bar(), isEmpty);
  });

  test('a server answering 501 turns bookmarks off', () async {
    server.handle = (_) => error(501, 'license_error');
    await expectLater(session.bookmarks.refresh(channelId), throwsA(anything));
    expect((await session.db.features()).bookmarks, isFalse);
    server.seen.clear();
    await session.bookmarks.refresh(channelId);
    expect(server.seen, isEmpty);
  });

  test('bookmarks added, changed and deleted elsewhere follow', () async {
    await receive('channel_bookmark_created', {
      'bookmark': jsonEncode(_link('b1', 'Handbook')),
    });
    expect(await bar(), ['Handbook']);
    // Someone else's edit comes back as a new copy replacing the old one.
    await receive('channel_bookmark_updated', {
      'bookmarks': jsonEncode({
        'updated': _link('b9', 'Staff handbook', at: 3000),
        'deleted': _link('b1', 'Handbook', deletedAt: 3000),
      }),
    });
    expect(await bar(), ['Staff handbook']);
    await receive('channel_bookmark_deleted', {
      'bookmark': jsonEncode(_link('b9', 'Staff handbook', deletedAt: 4000)),
    });
    expect(await bar(), isEmpty);
  });

  test('adding a link sends it and shows the stored answer', () async {
    server.handle = (r) => switch ((r.method, r.path)) {
      ('POST', '/api/v4/channels/$channelId/bookmarks') => ok({
        ...?(r.json as Map<String, Object?>?),
        'id': 'new1',
        'channel_id': channelId,
        'create_at': 5000,
      }),
      _ => error(404, 'not_found'),
    };
    await session.bookmarks.addLink(
      channelId,
      name: 'Tides',
      link: Uri.parse('https://example.com/tides'),
    );
    final sent = server.seen.single.body;
    expect(sent['type'], 'link');
    expect(sent['link_url'], 'https://example.com/tides');
    expect(await bar(), ['Tides']);
  });

  group('rights', () {
    BookmarkRights rights(
      String type, {
      bool guest = false,
      bool archived = false,
      Set<String> granted = const {},
    }) => bookmarkRights(
      type,
      archived: archived,
      guest: guest,
      roles: const {'channel_user'},
      granted: {'channel_user': granted},
    );

    test('come from the channel type permissions', () {
      final r = rights('O', granted: {BookmarkPermission.addPublic});
      expect(r.add, isTrue);
      expect(r.edit, isFalse);
      expect(rights('P', granted: {BookmarkPermission.addPublic}).add, isFalse);
    });

    test('members may change bookmarks of direct messages, guests never', () {
      expect(rights('D').delete, isTrue);
      expect(rights('G', guest: true).add, isFalse);
      expect(
        rights(
          'O',
          archived: true,
          granted: {BookmarkPermission.addPublic},
        ).add,
        isFalse,
      );
    });
  });

  test('typed addresses become web links', () {
    expect(bookmarkLink('example.com/a').toString(), 'https://example.com/a');
    expect(bookmarkLink('http://example.org').toString(), 'http://example.org');
    expect(bookmarkLink('not a link'), isNull);
    expect(bookmarkLink('javascript:alert(1)'), isNull);
  });
}

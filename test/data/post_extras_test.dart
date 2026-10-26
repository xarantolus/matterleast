import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/preference_keys.dart';

const channel = 'ch000000000000000000000c01';
const other = 'ch000000000000000000000c02';
const linkedId = 'po000000000000000000000l01';
final server = Uri.parse('https://chat.example.test');

Map<String, Object?> post(
  String id,
  int minute, {
  String message = 'hello',
  String user = 'u1',
  String channelId = channel,
  Map<String, Object?>? metadata,
}) => {
  'id': id,
  'channel_id': channelId,
  'user_id': user,
  'create_at': DateTime.utc(2026, 10, 26, 9, minute).millisecondsSinceEpoch,
  'message': message,
  'metadata': ?metadata,
};

void main() {
  late ServerDatabase db;
  late ServerStore store;

  setUp(() async {
    db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
    store = ServerStore(db);
    await db.setSyncText(SyncKeys.currentUserId, 'me');
    await store.applyUsers([
      api.User.fromJson({'id': 'u1', 'username': 'wren'}),
      api.User.fromJson({'id': 'u2', 'username': 'heron'}),
      api.User.fromJson({'id': 'me', 'username': 'kite'}),
    ]);
    await store.applyChannel(
      api.Channel.fromJson({
        'id': other,
        'team_id': 't1',
        'name': 'pier',
        'display_name': 'Pier',
        'type': 'O',
      }),
    );
  });
  tearDown(() => db.close());

  Future<void> permalinkPreviews({required bool on}) =>
      store.applyConfig('client_config', {'EnablePermalinkPreviews': '$on'});

  Future<void> receive(
    List<Map<String, Object?>> posts, {
    String channelId = channel,
  }) => store.applyChannelPage(
    channelId: channelId,
    page: api.PostList.fromJson({
      'order': [for (final p in posts.reversed) p['id']],
      'posts': {for (final p in posts) p['id']! as String: p},
    }),
    kind: PageKind.page,
  );

  Future<List<PostItem>> shown() async =>
      (await ConversationViews(db, server: server)
              .channel(
                channel,
                limit: 50,
                openedAt: DateTime.utc(2026, 10, 26, 10),
              )
              .first)
          .posts;

  group('a link to another message', () {
    test('shows the message the server embedded, with its author and '
        'channel', () async {
      await permalinkPreviews(on: true);
      await receive([
        post(
          'p1',
          1,
          message: 'see $server/harbor/pl/$linkedId',
          metadata: {
            'embeds': [
              {
                'type': 'permalink',
                'data': {
                  'post_id': linkedId,
                  'team_name': 'harbor',
                  'channel_display_name': 'Dock Ops',
                  'channel_type': 'O',
                  'post': post(linkedId, 0, user: 'u2', message: 'tide'),
                },
              },
            ],
          },
        ),
      ]);
      final linked = (await shown()).single.linked;
      expect(linked?.postId, linkedId);
      expect(linked?.authorName, 'heron');
      expect(linked?.channelName, 'Dock Ops');
      expect(linked?.teamName, 'harbor');
      expect(linked?.message, 'tide');
    });

    test(
      'without an embed, a stored message the link points to shows',
      () async {
        await permalinkPreviews(on: true);
        await receive([
          post(linkedId, 0, user: 'u2', message: 'gate code', channelId: other),
        ], channelId: other);
        await receive([
          post('p1', 1, message: 'look: <$server/harbor/pl/$linkedId>'),
        ]);
        final linked = (await shown()).single.linked;
        expect(linked?.message, 'gate code');
        expect(linked?.channelName, 'Pier');
        expect(linked?.authorName, 'heron');
      },
    );

    test(
      'shows nothing when the server turned permalink previews off',
      () async {
        await permalinkPreviews(on: false);
        await receive([
          post(linkedId, 0, user: 'u2', message: 'gate code', channelId: other),
        ], channelId: other);
        await receive([post('p1', 1, message: '$server/harbor/pl/$linkedId')]);
        expect((await shown()).single.linked, isNull);
      },
    );
  });

  test('a saved message is marked; unsaving takes the mark away', () async {
    await receive([post('p1', 1), post('p2', 2)]);
    final pref = api.Preference(
      userId: 'me',
      category: Prefs.flaggedPost,
      name: 'p1',
      value: 'true',
    );
    await store.applyPreferences([pref]);
    var posts = await shown();
    expect({for (final p in posts) p.id: p.saved}, {'p1': true, 'p2': false});

    await store.deletePreferences([pref]);
    posts = await shown();
    expect(posts.any((p) => p.saved), isFalse);
  });

  test('acknowledgements show who acknowledged; taking one back removes '
      'only that person', () async {
    await receive([
      post(
        'p1',
        1,
        metadata: {
          'priority': {'priority': 'important', 'requested_ack': true},
          'acknowledgements': [
            {
              'user_id': 'u2',
              'post_id': 'p1',
              'acknowledged_at': DateTime.utc(
                2026,
                10,
                26,
                9,
                5,
              ).millisecondsSinceEpoch,
            },
          ],
        },
      ),
    ]);
    var p1 = (await shown()).single;
    expect([for (final p in p1.acknowledgedBy) p.name], ['heron']);
    expect(p1.acknowledgedAt, isNull);

    final mine = api.PostAcknowledgement(
      userId: 'me',
      postId: 'p1',
      acknowledgedAt: DateTime.utc(2026, 10, 26, 9, 6),
    );
    await store.applyAcknowledgement(mine, added: true);
    p1 = (await shown()).single;
    expect([for (final p in p1.acknowledgedBy) p.name], ['heron', 'kite']);
    expect(p1.acknowledgedAt, DateTime.utc(2026, 10, 26, 9, 6));

    await store.applyAcknowledgement(mine, added: false);
    p1 = (await shown()).single;
    expect([for (final p in p1.acknowledgedBy) p.name], ['heron']);
    expect(p1.acknowledgedAt, isNull);
  });
}

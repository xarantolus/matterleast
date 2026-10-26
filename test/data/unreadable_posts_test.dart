import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/broken_posts.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/post_list.dart';

const channel = 'ch000000000000000000000c01';

Map<String, Object?> post(String id, int minute, {Object? props}) => {
  'id': id,
  'channel_id': channel,
  'user_id': 'u1',
  'create_at': DateTime.utc(2026, 10, 26, 9, minute).millisecondsSinceEpoch,
  'message': 'secret words in $id',
  'props': ?props,
};

/// Props nested deeper than the app can write back out, as decoded from
/// the server's answer.
Map<String, Object?> deeplyNested() =>
    jsonDecode('{"nest":${'{"a":' * 100000}1${'}' * 100000}}')
        as Map<String, Object?>;

void main() {
  late ServerDatabase db;
  late ServerStore store;

  setUp(() async {
    db = ServerDatabase(DatabaseConnection(NativeDatabase.memory()));
    store = ServerStore(db);
    await store.applyUsers([
      api.User.fromJson({'id': 'u1', 'username': 'wren'}),
    ]);
  });
  tearDown(() => db.close());

  Future<void> receivePage(List<Map<String, Object?>> posts) =>
      store.applyChannelPage(
        channelId: channel,
        page: api.PostList.fromJson({
          'order': [for (final p in posts.reversed) p['id']],
          'posts': {for (final p in posts) p['id']! as String: p},
        }),
        kind: PageKind.page,
      );

  Future<List<PostItem>> shown() async =>
      (await ConversationViews(db)
              .channel(
                channel,
                limit: 50,
                openedAt: DateTime.utc(2026, 10, 26, 10),
              )
              .first)
          .posts;

  test('a message the app cannot store keeps its place as a placeholder, '
      'and the rest of the page shows', () async {
    await receivePage([
      post('p1', 1),
      post('p2', 2, props: deeplyNested()),
      post('p3', 3),
    ]);
    final posts = await shown();
    expect([for (final p in posts) p.id], ['p3', 'p2', 'p1']);
    final broken = posts[1];
    expect(broken.unreadable, isTrue);
    expect(broken.authorName, 'wren');
    expect(broken.message, isEmpty);
    expect(posts[0].unreadable, isFalse);
    expect(posts[0].message, 'secret words in p3');

    final details = unreadableDetails(broken);
    expect(details, contains('p2'));
    expect(details, contains('StackOverflowError'));
    expect(details, isNot(contains('secret')));
  });

  test('a readable copy fetched later replaces the placeholder', () async {
    await receivePage([post('p2', 2, props: deeplyNested())]);
    expect((await shown()).single.unreadable, isTrue);
    await receivePage([post('p2', 2)]);
    final fixed = (await shown()).single;
    expect(fixed.unreadable, isFalse);
    expect(fixed.message, 'secret words in p2');
  });

  test('a post the generated code cannot read stands in with what can be '
      'read, and one without a time is left out', () async {
    Never fail(Map<String, Object?> _) => throw const FormatException();
    final standIn = decodePost(post('p4', 4), decode: fail)!;
    expect(decodeProblemOf(standIn), 'FormatException');
    expect(standIn.message, isNull);
    final timeless = decodePost({
      'id': 'p5',
      'channel_id': channel,
    }, decode: fail)!;
    await store.applyChannelPage(
      channelId: channel,
      page: api.PostList(
        order: const ['p5', 'p4', 'p1'],
        posts: {
          'p1': api.Post.fromJson(post('p1', 1)),
          'p4': standIn,
          'p5': timeless,
        },
      ),
      kind: PageKind.page,
    );
    final posts = await shown();
    expect([for (final p in posts) p.id], ['p4', 'p1']);
    expect(posts.first.unreadable, isTrue);
    expect(unreadableDetails(posts.first), contains('FormatException'));
  });
}

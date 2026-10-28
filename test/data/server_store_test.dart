import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_ranges.dart';

import '../support/memory_database.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

Map<String, Object?> fixtureMap(String name) =>
    fixture(name)! as Map<String, Object?>;

List<Map<String, Object?>> fixtureList(String name) =>
    (fixture(name)! as List).cast<Map<String, Object?>>();

api.Post post(
  String id, {
  required int createAt,
  String channel = 'c1',
  String user = 'u2',
  String root = '',
  String message = 'hi',
  String pendingId = '',
}) => api.Post.fromJson({
  'id': id,
  'channel_id': channel,
  'user_id': user,
  'root_id': root,
  'create_at': createAt,
  'message': message,
  'pending_post_id': pendingId,
});

api.PostList pageOf(List<api.Post> posts) => api.PostList.fromJson({
  'order': [for (final p in posts) p.id],
  'posts': {
    for (final p in posts)
      p.id!: {
        'id': p.id,
        'channel_id': p.channelId,
        'user_id': p.userId,
        'root_id': p.rootId,
        'create_at': p.createAt!.millisecondsSinceEpoch,
        'message': p.message,
        'pending_post_id': p.pendingPostId,
      },
  },
});

void main() {
  late ServerDatabase db;
  late ServerStore store;

  setUp(() {
    db = memoryDatabase();
    store = ServerStore(db);
  });

  tearDown(() => db.close());

  group('a channel created while a refresh is running', () {
    final empty = api.OrderedSidebarCategories.fromJson({
      'order': <String>[],
      'categories': <Object>[],
    });

    test('is not removed when that refresh was answered without it', () async {
      final now = DateTime.utc(2026, 1, 1, 12);
      store = ServerStore(db, clock: () => now);
      final started = now.subtract(const Duration(seconds: 2));
      await store.applyChannels(
        channels: [
          api.Channel.fromJson({'id': 'dm1', 'name': 'a__b', 'type': 'D'}),
        ],
        members: [
          api.ChannelMember.fromJson({'channel_id': 'dm1', 'user_id': 'me'}),
        ],
      );
      await store.applyTeamChannels(
        teamId: 't1',
        channels: const [],
        members: const [],
        categories: empty,
        syncedAt: started,
      );
      expect(await db.select(db.channels).get(), hasLength(1));
      expect(await db.select(db.myChannels).get(), hasLength(1));
    });

    test('is removed by a refresh that started after it was stored', () async {
      var now = DateTime.utc(2026, 1, 1, 12);
      store = ServerStore(db, clock: () => now);
      await store.applyChannels(
        channels: [
          api.Channel.fromJson({'id': 'dm1', 'name': 'a__b', 'type': 'D'}),
        ],
        members: [
          api.ChannelMember.fromJson({'channel_id': 'dm1', 'user_id': 'me'}),
        ],
      );
      now = now.add(const Duration(seconds: 5));
      await store.applyTeamChannels(
        teamId: 't1',
        channels: const [],
        members: const [],
        categories: empty,
        syncedAt: now,
      );
      expect(await db.select(db.channels).get(), isEmpty);
    });
  });

  group('entry data', () {
    test('channels, members and categories land in their tables', () async {
      await store.applyMe(api.User.fromJson(fixtureMap('me')));
      await store.applyChannels(
        channels: fixtureList('channels').map(api.Channel.fromJson),
        members: fixtureList('channel_members').map(api.ChannelMember.fromJson),
        categories: api.OrderedSidebarCategories.fromJson(
          fixtureMap('categories'),
        ),
      );
      final channels = await db.select(db.channels).get();
      expect(channels.map((c) => c.name), contains('engineering'));
      final members = await db.select(db.myChannels).get();
      expect(members.length, channels.length);
      final categories = await db.select(db.categories).get();
      expect(categories.map((c) => c.displayName), contains('Projects'));
      final links = await db.select(db.categoryChannels).get();
      expect(links, isNotEmpty);
      expect(await db.syncText(SyncKeys.currentUserId), isNotEmpty);
    });

    test('a second sync keeps local-only columns', () async {
      final channels = fixtureList('channels').map(api.Channel.fromJson);
      final members = fixtureList('channel_members')
          .map(api.ChannelMember.fromJson);
      await store.applyChannels(channels: channels, members: members);
      final first = (await db.select(db.myChannels).get()).first;
      final mark = DateTime.utc(2026, 1, 1);
      await (db.update(db.myChannels)
            ..where((m) => m.channelId.equals(first.channelId)))
          .write(MyChannelsCompanion(postsFetchedAt: Value(mark)));
      await store.applyChannels(channels: channels, members: members);
      final again = await (db.select(
        db.myChannels,
      )..where((m) => m.channelId.equals(first.channelId))).getSingle();
      expect(again.postsFetchedAt, mark);
    });

    test('unread is the server counter difference', () async {
      await store.applyChannels(
        channels: fixtureList('channels').map(api.Channel.fromJson),
        members: fixtureList('channel_members').map(api.ChannelMember.fromJson),
      );
      final rows = await (db.select(db.channels).join([
        innerJoin(
          db.myChannels,
          db.myChannels.channelId.equalsExp(db.channels.id),
        ),
      ])).get();
      final unread = {
        for (final row in rows)
          row.readTable(db.channels).name:
              row.readTable(db.channels).totalMsgCount -
              row.readTable(db.myChannels).msgCount,
      };
      expect(unread['engineering'], greaterThan(0));
      expect(unread['town-square'], greaterThan(0));
    });
  });

  group('post pages and ranges', () {
    test('a recorded first page stores posts, files and reactions', () async {
      final page = api.PostList.fromJson(fixtureMap('posts_page'));
      final channelId = page.posts!.values.first.channelId!;
      final outcome = await store.applyChannelPage(
        channelId: channelId,
        page: page,
        kind: PageKind.page,
      );
      expect(outcome.stored, page.posts!.length);
      expect(await db.select(db.files).get(), isNotEmpty);
      expect(await db.select(db.reactions).get(), isNotEmpty);
      final ranges = await store.rangesFor('channel', channelId);
      expect(ranges, hasLength(1));
      expect(ranges.single.reachesStart, isTrue);
      final rows = await (db.select(
        db.posts,
      )..where((p) => p.channelId.equals(channelId))).get();
      expect(rows.any((p) => p.reactionCount > 0), isTrue);
      expect(rows.any((p) => p.fileCount > 0), isTrue);
    });

    test('a followed thread without metadata keeps reactions', () async {
      final page = api.PostList.fromJson(fixtureMap('posts_page'));
      final channelId = page.posts!.values.first.channelId!;
      await store.applyChannelPage(
        channelId: channelId,
        page: page,
        kind: PageKind.page,
      );
      final reacted = (await (db.select(
        db.posts,
      )..where((p) => p.reactionCount.isBiggerThanValue(0))).get()).first;
      final json = page.posts![reacted.id]!.toJson()..remove('metadata');
      await store.applyThreads('t1', [
        api.UserThread.fromJson({
          'id': reacted.id,
          'reply_count': 2,
          'post': json,
        }),
      ]);
      final after = await (db.select(
        db.posts,
      )..where((p) => p.id.equals(reacted.id))).getSingle();
      expect(after.reactionCount, reacted.reactionCount);
      expect(after.metadataJson, reacted.metadataJson);
      expect(
        await (db.select(
          db.reactions,
        )..where((r) => r.postId.equals(reacted.id))).get(),
        hasLength(reacted.reactionCount),
      );
    });

    test('older history grows the range down and fuses', () async {
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p5', createAt: 500), post('p4', createAt: 400)]),
        kind: PageKind.page,
        requested: 2,
      );
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p3', createAt: 300), post('p2', createAt: 200)]),
        kind: PageKind.before,
        anchor: DateTime.fromMillisecondsSinceEpoch(400, isUtc: true),
        requested: 2,
      );
      final ranges = await store.rangesFor('channel', 'c1');
      expect(ranges.single.earliest.millisecondsSinceEpoch, 200);
      expect(ranges.single.latest.millisecondsSinceEpoch, 500);
      expect(ranges.single.reachesStart, isFalse);
    });

    test('a since refresh raises the range and the watermark', () async {
      await store.applyChannels(
        channels: [
          api.Channel.fromJson({'id': 'c1', 'name': 'c', 'type': 'O'}),
        ],
        members: [
          api.ChannelMember.fromJson({'channel_id': 'c1', 'user_id': 'me'}),
        ],
      );
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p1', createAt: 100)]),
        kind: PageKind.page,
      );
      final outcome = await store.applyChannelPage(
        channelId: 'c1',
        page: api.PostList.fromJson({
          'order': ['p2'],
          'posts': {
            'p2': {
              'id': 'p2',
              'channel_id': 'c1',
              'user_id': 'u2',
              'create_at': 200,
              'update_at': 250,
              'message': 'new',
            },
          },
        }),
        kind: PageKind.since,
      );
      expect(outcome.capped, isFalse);
      final range = (await store.rangesFor('channel', 'c1')).single;
      expect(range.latest.millisecondsSinceEpoch, 200);
      final mine = await db.select(db.myChannels).getSingle();
      expect(mine.postsFetchedAt!.millisecondsSinceEpoch, 250);
    });

    test('a since answer at the cap leaves the range alone', () async {
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p1', createAt: 100)]),
        kind: PageKind.page,
      );
      final many = [
        for (var i = 0; i < sinceCap; i++) post('q$i', createAt: 1000 + i),
      ];
      final outcome = await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf(many),
        kind: PageKind.since,
      );
      expect(outcome.capped, isTrue);
      final range = (await store.rangesFor('channel', 'c1')).single;
      expect(range.latest.millisecondsSinceEpoch, 100);
      expect((await db.select(db.posts).get()).length, sinceCap + 1);
    });

    test('a since answer that only deletes keeps a placeholder', () async {
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p1', createAt: 100, message: 'bye')]),
        kind: PageKind.page,
      );
      await store.applyChannelPage(
        channelId: 'c1',
        page: api.PostList.fromJson({
          'order': <String>[],
          'posts': {
            'p1': {
              'id': 'p1',
              'channel_id': 'c1',
              'user_id': 'u2',
              'create_at': 100,
              'delete_at': 300,
              'message': '',
            },
          },
        }),
        kind: PageKind.since,
      );
      final row = await db.select(db.posts).getSingle();
      expect(row.deleteAt, isNotNull);
      expect(row.message, '');
    });
  });

  group('live changes', () {
    setUp(() async {
      await store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': 'c1',
            'name': 'c',
            'type': 'O',
            'total_msg_count': 1,
            'total_msg_count_root': 1,
          }),
        ],
        members: [
          api.ChannelMember.fromJson({
            'channel_id': 'c1',
            'user_id': 'me',
            'msg_count': 1,
            'msg_count_root': 1,
          }),
        ],
      );
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p1', createAt: 100)]),
        kind: PageKind.page,
      );
    });

    test('a post first stored by a fetch still moves its channel up', () async {
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p2', createAt: 200)]),
        kind: PageKind.since,
      );
      await store.applyLivePost(
        post('p2', createAt: 200),
        fromSelf: false,
        mentionsMe: false,
      );
      final at = DateTime.fromMillisecondsSinceEpoch(200, isUtc: true);
      final channel = await db.select(db.channels).getSingle();
      expect(channel.lastPostAt, at);
      expect(channel.lastRootPostAt, at);
    });

    test('an older page leaves the last-post time where it is', () async {
      await store.applyLivePost(
        post('p3', createAt: 300),
        fromSelf: false,
        mentionsMe: false,
      );
      await store.applyChannelPage(
        channelId: 'c1',
        page: pageOf([post('p0', createAt: 50)]),
        kind: PageKind.before,
        anchor: DateTime.fromMillisecondsSinceEpoch(100, isUtc: true),
      );
      final channel = await db.select(db.channels).getSingle();
      expect(
        channel.lastPostAt,
        DateTime.fromMillisecondsSinceEpoch(300, isUtc: true),
      );
    });

    test('a replayed post is not counted twice', () async {
      for (var i = 0; i < 2; i++) {
        await store.applyLivePost(
          post('p2', createAt: 200),
          fromSelf: false,
          mentionsMe: true,
        );
      }
      final channel = await db.select(db.channels).getSingle();
      final mine = await db.select(db.myChannels).getSingle();
      expect(channel.totalMsgCount - mine.msgCount, 1);
      expect(mine.mentionCount, 1);
    });

    test("someone else's post makes the channel unread", () async {
      await store.applyLivePost(
        post('p2', createAt: 200),
        fromSelf: false,
        mentionsMe: true,
      );
      final channel = await db.select(db.channels).getSingle();
      final mine = await db.select(db.myChannels).getSingle();
      expect(channel.totalMsgCount - mine.msgCount, 1);
      expect(mine.mentionCount, 1);
      expect(
        (await store.rangesFor('channel', 'c1')).single.latest,
        DateTime.fromMillisecondsSinceEpoch(200, isUtc: true),
      );
    });

    test('our own post replaces its pending row and reads as viewed', () async {
      await db
          .into(db.posts)
          .insert(
            PostsCompanion.insert(
              id: 'me:1',
              channelId: 'c1',
              userId: 'me',
              createAt: DateTime.fromMillisecondsSinceEpoch(150, isUtc: true),
              pendingPostId: const Value('me:1'),
              sendState: const Value('pending'),
            ),
          );
      await store.applyLivePost(
        post('p2', createAt: 200, user: 'me', pendingId: 'me:1'),
        fromSelf: true,
        mentionsMe: false,
      );
      final rows = await db.select(db.posts).get();
      expect(rows.map((p) => p.id), containsAll(['p1', 'p2']));
      expect(rows.any((p) => p.id == 'me:1'), isFalse);
      final channel = await db.select(db.channels).getSingle();
      final mine = await db.select(db.myChannels).getSingle();
      expect(channel.totalMsgCount - mine.msgCount, 0);
    });

    api.Post linkPost({
      required String message,
      required List<Object> embeds,
    }) => api.Post.fromJson({
      'id': 'p5',
      'channel_id': 'c1',
      'user_id': 'u2',
      'create_at': 500,
      'message': message,
      'metadata': jsonDecode(jsonEncode({'embeds': embeds})),
    });
    const link = 'https://garden.example/notes';
    const card = {
      'type': 'opengraph',
      'url': link,
      'data': {'title': 'Garden notes', 'description': 'Tomatoes and basil'},
    };
    Future<String?> previewTitle() async => PostDetails.decode(
      null,
      (await (db.select(
        db.posts,
      )..where((p) => p.id.equals('p5'))).getSingle()).metadataJson,
    ).preview?.title;

    test('a copy without the link preview keeps the stored one', () async {
      await store.applyLivePost(
        linkPost(message: 'Look: $link', embeds: [card]),
        fromSelf: false,
        mentionsMe: false,
      );
      // The server's fetch of the linked page timed out this time.
      await store.applyChannelPage(
        channelId: 'c1',
        page: api.PostList.fromJson({
          'order': ['p5'],
          'posts': {
            'p5': jsonDecode(
              jsonEncode(
                linkPost(
                  message: 'Look: $link',
                  embeds: [
                    {'type': 'link', 'url': link},
                  ],
                ),
              ),
            ),
          },
        }),
        kind: PageKind.page,
      );
      expect(await previewTitle(), 'Garden notes');
      await store.applyEdit(linkPost(message: 'Look: $link', embeds: []));
      expect(await previewTitle(), 'Garden notes');
    });

    test('an edit that drops the link drops its preview', () async {
      await store.applyLivePost(
        linkPost(message: 'Look: $link', embeds: [card]),
        fromSelf: false,
        mentionsMe: false,
      );
      await store.applyEdit(linkPost(message: 'Never mind', embeds: []));
      expect(await previewTitle(), isNull);
    });

    test('edits update in place and deletes leave a placeholder', () async {
      await store.applyEdit(post('p1', createAt: 100, message: 'edited'));
      expect((await db.select(db.posts).getSingle()).message, 'edited');
      await store.applyDelete('p1', at: DateTime.utc(2026));
      final row = await db.select(db.posts).getSingle();
      expect(row.deleteAt, isNotNull);
      expect(row.message, '');
    });

    test('reactions come and go with their count', () async {
      final reaction = api.Reaction.fromJson({
        'post_id': 'p1',
        'user_id': 'u3',
        'emoji_name': 'tada',
      });
      await store.applyReaction(reaction, added: true);
      expect((await db.select(db.posts).getSingle()).reactionCount, 1);
      await store.applyReaction(reaction, added: false);
      expect((await db.select(db.posts).getSingle()).reactionCount, 0);
    });

    test('marking viewed zeroes the difference and the mentions', () async {
      await store.applyLivePost(
        post('p2', createAt: 200),
        fromSelf: false,
        mentionsMe: true,
      );
      await store.markViewed('c1', at: DateTime.utc(2026));
      final channel = await db.select(db.channels).getSingle();
      final mine = await db.select(db.myChannels).getSingle();
      expect(channel.totalMsgCount - mine.msgCount, 0);
      expect(mine.mentionCount, 0);
      expect(mine.lastViewedAt, DateTime.utc(2026));
    });

    test('a recorded thread records its reply range', () async {
      final thread = api.PostList.fromJson(fixtureMap('thread'));
      final rootId = thread.order.first;
      await store.applyThreadPage(rootId: rootId, page: thread);
      final ranges = await store.rangesFor('thread', rootId);
      expect(ranges, hasLength(1));
      expect(ranges.single.earliest.isBefore(ranges.single.latest), isTrue);
      expect(newestRange(ranges), ranges.single);
    });
  });

  group('entry and team changes', () {
    Future<void> seed() => store.applyChannels(
      channels: fixtureList('channels').map(api.Channel.fromJson),
      members: fixtureList('channel_members').map(api.ChannelMember.fromJson),
      categories: api.OrderedSidebarCategories.fromJson(
        fixtureMap('categories'),
      ),
    );

    test('leaving a team keeps the direct messages', () async {
      await seed();
      final teamId =
          fixtureList('channels')
                  .map((c) => c['team_id'])
                  .firstWhere((id) => id != '')!
              as String;
      await store.removeTeam(teamId);
      final left = await db.select(db.channels).get();
      expect(left, isNotEmpty);
      expect(left.every((c) => c.teamId.isEmpty), isTrue);
      expect(await db.select(db.categories).get(), isEmpty);
      expect((await db.select(db.myChannels).get()).length, left.length);
    });

    test('a category change elsewhere keeps its place and collapse', () async {
      await seed();
      final projects = (await db.select(db.categories).get()).firstWhere(
        (c) => c.displayName == 'Projects',
      );
      await store.setCategoryCollapsed(projects.id, collapsed: true);
      await store.applyCategoryUpdates([
        api.SidebarCategoryWithChannels.fromJson({
          'id': projects.id,
          'team_id': projects.teamId,
          'type': 'custom',
          'display_name': 'Projects',
          'sort_order': 999,
          'channel_ids': ['only-one'],
        }),
      ]);
      final after = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(projects.id))).getSingle();
      expect(after.sortOrder, projects.sortOrder);
      expect(after.collapsed, isTrue);
      final links = await (db.select(
        db.categoryChannels,
      )..where((cc) => cc.categoryId.equals(projects.id))).get();
      expect(links.map((l) => l.channelId), ['only-one']);
    });

    test('unread threads replace the unread set of their team', () async {
      api.UserThread thread(String id, int unread) => api.UserThread.fromJson({
        'id': id,
        'reply_count': 3,
        'unread_replies': unread,
        'post': {'id': id, 'channel_id': 'c1', 'create_at': 1, 'user_id': 'u'},
      });
      await store.applyThreads('t1', [thread('a', 2), thread('b', 1)]);
      await store.applyThreads('t1', [thread('b', 4)], allUnread: true);
      final rows = {
        for (final t in await db.select(db.threads).get())
          t.rootId: t.unreadReplies,
      };
      expect(rows, {'a': 0, 'b': 4});
    });

    test('presence updates stored users only', () async {
      await store.applyUsers([
        api.User.fromJson({'id': 'u1', 'username': 'bob'}),
      ]);
      await store.applyStatuses({'u1': 'away', 'u9': 'online'});
      final users = await db.select(db.users).get();
      expect(users.single.status, 'away');
    });
  });
}

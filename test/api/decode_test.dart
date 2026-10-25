import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

Map<String, Object?> fixtureMap(String name) =>
    fixture(name)! as Map<String, Object?>;

List<Map<String, Object?>> fixtureList(String name) =>
    (fixture(name)! as List).cast<Map<String, Object?>>();

void main() {
  group('lenient decoding', () {
    test('a post with odd types still decodes', () {
      final post = Post.fromJson({
        'id': 'p1',
        'create_at': 1761300000000,
        'edit_at': 0,
        'update_at': '1761300000001',
        'message': 42,
        'is_pinned': 'true',
        'reply_count': 3.0,
        'file_ids': ['f1', 7, null],
        'participants': [
          {'id': 'u1', 'username': 'alice', 'is_bot': false},
          'garbage',
        ],
        'props': {'from_bot': 'true', 'attachments': <Object?>[]},
        'metadata': 'not a map',
        'hashtags': '#x',
        'unknown_new_field': {'a': 1},
      });
      expect(post.id, 'p1');
      expect(post.createAt, DateTime.utc(2025, 10, 24, 10, 0));
      expect(post.editAt, isNull);
      expect(post.updateAt!.millisecondsSinceEpoch, 1761300000001);
      expect(post.message, isNull);
      expect(post.isPinned, isTrue);
      expect(post.replyCount, 3);
      expect(post.fileIds, ['f1']);
      expect(post.participants.single.username, 'alice');
      expect(post.props!['from_bot'], 'true');
      expect(post.metadata, isNull);
    });

    test('an empty object decodes to defaults', () {
      final post = Post.fromJson({});
      expect(post.fileIds, isEmpty);
      expect(post.createAt, isNull);
      expect(post.participants, isEmpty);
    });

    test('a map of posts drops broken entries instead of throwing', () {
      final list = PostList.fromJson({
        'order': ['a', 'b'],
        'posts': {
          'a': {'id': 'a', 'message': 'hi'},
          'b': 'nope',
        },
      });
      expect(list.order, ['a', 'b']);
      expect(list.posts!.keys, ['a']);
    });
  });

  group('recorded server responses', () {
    test('a channel page has every ordered post, with files and reactions', () {
      final page = PostList.fromJson(fixtureMap('posts_page'));
      expect(page.order, isNotEmpty);
      expect(page.posts!.keys.toSet(), containsAll(page.order));
      final withFiles = page.posts!.values
          .where((p) => p.metadata?.files.isNotEmpty ?? false)
          .toList();
      expect(withFiles, isNotEmpty);
      final image = withFiles.first.metadata!.files.firstWhere(
        (f) => f.hasPreviewImage ?? false,
      );
      expect(image.width, greaterThan(0));
      expect(image.miniPreview, isNotNull);
      final root = page.posts!.values.firstWhere(
        (p) => (p.replyCount ?? 0) > 0,
      );
      expect(root.metadata!.reactions, isNotEmpty);
      expect(root.createAt!.isUtc, isTrue);
    });

    test('a thread carries its replies in order', () {
      final thread = PostList.fromJson(fixtureMap('thread'));
      final root = thread.posts![thread.order.first]!;
      final replies = thread.posts!.values.where((p) => p.rootId == root.id);
      expect(replies.length, 25);
    });

    test('channel members carry the collapsed-thread counts', () {
      final members = fixtureList('channel_members')
          .map(ChannelMember.fromJson);
      expect(members.any((m) => (m.mentionCount ?? 0) > 0), isTrue);
      expect(members.every((m) => m.msgCountRoot != null), isTrue);
    });

    test(
      'channels, users, teams, categories, emoji and preferences decode',
      () {
        final channels = fixtureList('channels').map(Channel.fromJson).toList();
        expect(channels.map((c) => c.name), contains('engineering'));
        expect(
          channels.firstWhere((c) => c.name == 'old-projects').deleteAt,
          isNotNull,
        );
        final me = User.fromJson(fixtureMap('me'));
        expect(me.username, 'alice');
        expect(me.isBot ?? false, isFalse);
        final teams = fixtureList('my_teams').map(Team.fromJson);
        expect(teams.map((t) => t.name), containsAll(['lighthouse', 'harbor']));
        final categories = OrderedSidebarCategories.fromJson(
          fixtureMap('categories'),
        );
        expect(
          categories.categories.map((c) => c.displayName),
          contains('Projects'),
        );
        final emoji = fixtureList('emoji').map(Emoji.fromJson);
        expect(
          emoji.map((e) => e.name),
          containsAll(['lighthouse', 'anchor-party']),
        );
        final preferences = fixtureList('preferences').map(Preference.fromJson);
        expect(
          preferences.any((p) => p.category == 'favorite_channel'),
          isTrue,
        );
        final statuses = fixtureList('statuses').map(Status.fromJson);
        expect(statuses.map((s) => s.status), contains('away'));
      },
    );

    test('the login error body is a server error with an id', () {
      final body = fixtureMap('login_failed');
      expect(body['id'], startsWith('api.user.login'));
      expect(body['status_code'], 401);
    });
  });
}

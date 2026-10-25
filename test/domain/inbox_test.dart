import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/inbox.dart';

import 'channel_list_test.dart' show channel, person;

DateTime at(int minute) => DateTime.utc(2026, 10, 25, 12, minute);

InboxPost post(
  String id, {
  required String channelId,
  String userId = 'bob',
  int minute = 0,
  String rootId = '',
  String message = 'hello',
}) => (
  id: id,
  channelId: channelId,
  rootId: rootId,
  userId: userId,
  createAt: at(minute),
  message: message,
  deleted: false,
);

void main() {
  final people = {'me': person('alice'), 'bob': person('bob')};

  test('rows show the picture of the author or the other person', () {
    final inbox = buildServerInbox(
      InboxSource(
        serverUrl: 's1',
        myId: 'me',
        people: {...people, 'carol': person('carol')},
        pictureUpdates: {'bob': 11, 'carol': 22},
        channels: {
          'dm': (
            teamId: '',
            input: channel('dm', type: 'D', name: 'bob__me', read: 8),
          ),
          'gm': (
            teamId: '',
            input: channel('gm', type: 'G', displayName: 'alice, bob', read: 8),
          ),
          'town': (teamId: 't1', input: channel('town')),
        },
        posts: {'m': post('m', channelId: 'town', userId: 'carol')},
        mentionIds: ['m'],
      ),
    );
    final byChannel = {for (final i in inbox.unread) i.channelId: i};
    expect(byChannel['dm']!.avatarUserId, 'bob');
    expect(byChannel['dm']!.avatarPictureUpdate, 11);
    expect(byChannel['gm']!.avatarUserId, isNull);
    final mention = inbox.mentions.single;
    expect(mention.avatarUserId, 'carol');
    expect(mention.avatarPictureUpdate, 22);
  });

  group('unread', () {
    test('unread direct messages, new mentions and threads, newest first', () {
      final inbox = buildServerInbox(
        InboxSource(
          serverUrl: 's1',
          myId: 'me',
          people: people,
          channels: {
            'dm': (
              teamId: '',
              input: channel(
                'dm',
                type: 'D',
                name: 'bob__me',
                total: 5,
                read: 3,
                lastPost: at(30).millisecondsSinceEpoch,
              ),
            ),
            'read-dm': (
              teamId: '',
              input: channel('read-dm', type: 'D', name: 'carol__me'),
            ),
            'town': (
              teamId: 't1',
              input: channel(
                'town',
                displayName: 'Town',
                lastViewed: at(10).millisecondsSinceEpoch,
              ),
            ),
          },
          teams: {'t1': 'Team One'},
          posts: {
            'old': post('old', channelId: 'town', minute: 5),
            'new': post('new', channelId: 'town', minute: 20),
            'own': post('own', channelId: 'town', minute: 25, userId: 'me'),
            'root': post('root', channelId: 'town', minute: 1),
          },
          mentionIds: ['own', 'new', 'old'],
          threads: [
            (
              rootId: 'root',
              channelId: 'town',
              teamId: 't1',
              lastReplyAt: at(40),
              unreadReplies: 3,
            ),
          ],
        ),
      );
      expect(
        [for (final i in inbox.unread) i.kind],
        [InboxKind.thread, InboxKind.direct, InboxKind.mention],
      );
      final dm = inbox.unread[1];
      expect(dm.title, 'bob');
      expect(dm.count, 2);
      expect(dm.preview, '2 new messages');
      expect(inbox.unread[2].postId, 'new');
      expect(inbox.unread[2].title, '#Town · Team One');
      expect(inbox.unread.first.count, 3);
      expect(inbox.mentions.map((m) => m.postId), ['own', 'new', 'old']);
      expect(inbox.mentions.map((m) => m.unread), [false, true, false]);
    });

    test('a stored newest post becomes the preview of a conversation', () {
      final inbox = buildServerInbox(
        InboxSource(
          serverUrl: 's1',
          myId: 'me',
          people: people,
          channels: {
            'dm': (
              teamId: '',
              input: channel(
                'dm',
                type: 'D',
                name: 'bob__me',
                total: 2,
                read: 1,
                lastPost: at(30).millisecondsSinceEpoch,
              ),
            ),
          },
          latestPosts: {
            'dm': post('p', channelId: 'dm', minute: 30, message: '**hi**'),
          },
        ),
      );
      expect(inbox.unread.single.preview, 'hi');
      expect(inbox.unread.single.postId, 'p');
    });

    test(
      'under collapsed threads a mention in a reply waits for its thread',
      () {
        final inbox = buildServerInbox(
          InboxSource(
            serverUrl: 's1',
            myId: 'me',
            collapsedThreads: true,
            channels: {
              'town': (teamId: 't1', input: channel('town', lastViewed: null)),
            },
            posts: {'r': post('r', channelId: 'town', rootId: 'root')},
            mentionIds: ['r'],
          ),
        );
        expect(inbox.unread, isEmpty);
        expect(inbox.mentions.single.rootId, 'root');
      },
    );

    test('muted conversations count only with mentions', () {
      final inbox = buildServerInbox(
        InboxSource(
          serverUrl: 's1',
          myId: 'me',
          channels: {
            'g': (
              teamId: '',
              input: channel('g', type: 'G', total: 4, read: 1, muted: true),
            ),
          },
        ),
      );
      expect(inbox.unread, isEmpty);
    });
  });

  test('servers merge newest first', () {
    InboxItem item(String server, int minute) => InboxItem(
      serverUrl: server,
      kind: InboxKind.saved,
      channelId: 'c',
      teamId: null,
      title: 't',
      avatarName: 'a',
      author: null,
      preview: '',
      place: null,
      time: at(minute),
      count: 0,
      unread: false,
      postId: '$server$minute',
    );
    ServerInbox saved(List<InboxItem> items) => ServerInbox(
      unread: const [],
      mentions: const [],
      threads: const [],
      saved: items,
      known: const {InboxFilter.saved},
    );
    final merged = mergeInbox([
      saved([item('a', 10), item('a', 1)]),
      saved([item('b', 5)]),
    ], InboxFilter.saved);
    expect(merged.map((i) => i.postId), ['a10', 'b5', 'a1']);
  });

  test('mention terms: keys, first name when asked, always @username', () {
    expect(mentionTerms(username: 'alice'), '@alice');
    expect(
      mentionTerms(
        username: 'alice',
        firstName: 'Alice',
        mentionKeys: 'deploy, @alice,@channel',
        firstNameKey: 'true',
      ),
      'deploy @alice Alice',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

final _t0 = DateTime.utc(2026, 3, 1, 12);

NotifyPost _post(
  String id, {
  String channel = 'town',
  String user = 'u-bob',
  int minute = 1,
  String message = 'hello',
  String rootId = '',
  String type = '',
  bool deleted = false,
}) => NotifyPost(
  id: id,
  channelId: channel,
  userId: user,
  createAt: _t0.add(Duration(minutes: minute)),
  message: message,
  rootId: rootId,
  type: type,
  deleted: deleted,
);

NotifyUser _me({
  Map<String, String> props = const {'push': 'mention'},
  bool crt = false,
  bool dnd = false,
}) => NotifyUser(
  id: 'u-me',
  username: 'kim',
  firstName: 'Kim',
  props: NotifyProps(props),
  collapsedThreads: crt,
  doNotDisturb: dnd,
);

const _open = NotifyChannel(id: 'town', type: 'O');
const _direct = NotifyChannel(id: 'dm', type: 'D');

void main() {
  group('what is notified', () {
    test('a direct message always, even with mentions only', () {
      expect(
        notifyKindOf(_post('p', channel: 'dm'), _direct, _me()),
        NotifyKind.direct,
      );
    });

    test('a channel message only when it mentions the user', () {
      expect(notifyKindOf(_post('p'), _open, _me()), isNull);
      expect(
        notifyKindOf(_post('p', message: 'ping @kim please'), _open, _me()),
        NotifyKind.direct,
      );
    });

    test('a mention needs the whole username, not a longer one', () {
      expect(
        notifyKindOf(_post('p', message: 'ask @kimberly'), _open, _me()),
        isNull,
      );
      expect(
        notifyKindOf(_post('p', message: 'thanks @kim.'), _open, _me()),
        NotifyKind.direct,
      );
    });

    test('mentions inside code do not count', () {
      expect(
        notifyKindOf(_post('p', message: 'run `@kim` now'), _open, _me()),
        isNull,
      );
    });

    test('@channel counts unless the user turned channel-wide off', () {
      final post = _post('p', message: '@channel standup');
      expect(notifyKindOf(post, _open, _me()), NotifyKind.direct);
      expect(
        notifyKindOf(
          post,
          _open,
          _me(props: {'push': 'mention', 'channel': 'false'}),
        ),
        isNull,
      );
      expect(
        notifyKindOf(
          post,
          const NotifyChannel(
            id: 'town',
            type: 'O',
            ignoreChannelMentions: true,
          ),
          _me(),
        ),
        isNull,
      );
    });

    test('first name and extra words count when set', () {
      final user = _me(
        props: {
          'push': 'mention',
          'first_name': 'true',
          'mention_keys': 'rocket',
        },
      );
      expect(
        notifyKindOf(_post('a', message: 'Kim, look'), _open, user),
        NotifyKind.direct,
      );
      expect(
        notifyKindOf(_post('b', message: 'the Rocket launched'), _open, user),
        NotifyKind.direct,
      );
      expect(
        notifyKindOf(_post('c', message: 'Kim, look'), _open, _me()),
        isNull,
      );
    });

    test('everything in a channel set to all, as other messages', () {
      expect(
        notifyKindOf(
          _post('p'),
          const NotifyChannel(id: 'town', type: 'O', push: 'all'),
          _me(),
        ),
        NotifyKind.other,
      );
      expect(
        notifyKindOf(_post('p'), _open, _me(props: {'push': 'all'})),
        NotifyKind.other,
      );
    });

    test('the channel level wins over the account level', () {
      expect(
        notifyKindOf(
          _post('p', channel: 'dm'),
          const NotifyChannel(id: 'dm', type: 'D', push: 'none'),
          _me(props: {'push': 'all'}),
        ),
        isNull,
      );
    });

    test(
      'nothing from muted channels, own posts, system messages, or in DND',
      () {
        const muted = NotifyChannel(id: 'dm', type: 'D', muted: true);
        expect(notifyKindOf(_post('p', channel: 'dm'), muted, _me()), isNull);
        expect(
          notifyKindOf(_post('p', channel: 'dm', user: 'u-me'), _direct, _me()),
          isNull,
        );
        expect(
          notifyKindOf(
            _post('p', channel: 'dm', type: 'system_join_channel'),
            _direct,
            _me(),
          ),
          isNull,
        );
        expect(
          notifyKindOf(
            _post('p', channel: 'dm', deleted: true),
            _direct,
            _me(),
          ),
          isNull,
        );
        expect(
          notifyKindOf(_post('p', channel: 'dm'), _direct, _me(dnd: true)),
          isNull,
        );
        expect(
          notifyKindOf(
            _post('p', channel: 'dm'),
            _direct,
            _me(props: {'push': 'none'}),
          ),
          isNull,
        );
      },
    );

    test('with collapsed threads, replies only in followed threads', () {
      final reply = _post('r', rootId: 'root');
      final all = const NotifyChannel(id: 'town', type: 'O', push: 'all');
      final user = _me(
        crt: true,
        props: {'push': 'all', 'push_threads': 'all'},
      );
      expect(notifyKindOf(reply, all, user), isNull);
      expect(
        notifyKindOf(
          reply,
          all,
          user,
          thread: const NotifyThread(following: true),
        ),
        NotifyKind.thread,
      );
      expect(
        notifyKindOf(
          reply,
          all,
          _me(crt: true, props: {'push': 'all', 'push_threads': 'none'}),
          thread: const NotifyThread(following: true),
        ),
        isNull,
      );
    });

    test('without collapsed threads, replies to the user by comments', () {
      final reply = _post('r', rootId: 'root');
      expect(
        notifyKindOf(
          reply,
          _open,
          _me(props: {'push': 'mention', 'comments': 'root'}),
          thread: const NotifyThread(rootAuthorIsMe: true),
        ),
        NotifyKind.thread,
      );
      expect(
        notifyKindOf(
          reply,
          _open,
          _me(props: {'push': 'mention', 'comments': 'never'}),
          thread: const NotifyThread(rootAuthorIsMe: true),
        ),
        isNull,
      );
    });
  });

  group('never twice', () {
    final channels = {'dm': const NotifyChannel(id: 'dm', type: 'D')};

    test('posts at or before the cursor do not alert again', () {
      final updates = conversationUpdates(
        notifiable: [(_post('a', channel: 'dm', minute: 1), NotifyKind.direct)],
        channels: channels,
        cursor: _t0.add(const Duration(minutes: 1)),
        notified: const {},
        collapsedThreads: false,
      );
      expect(updates, isEmpty);
    });

    test('notified ids do not alert again, but show with a new post', () {
      final old = (_post('a', channel: 'dm', minute: 2), NotifyKind.direct);
      final fresh = (_post('b', channel: 'dm', minute: 3), NotifyKind.direct);
      expect(
        conversationUpdates(
          notifiable: [old],
          channels: channels,
          cursor: _t0,
          notified: {'a'},
          collapsedThreads: false,
        ),
        isEmpty,
      );
      final updates = conversationUpdates(
        notifiable: [fresh, old],
        channels: channels,
        cursor: _t0,
        notified: {'a'},
        collapsedThreads: false,
      );
      expect(updates.single.posts.map((p) => p.id), ['a', 'b']);
    });

    test('read posts are left out, the newest few kept', () {
      final updates = conversationUpdates(
        notifiable: [
          for (var i = 1; i <= 10; i++)
            (_post('p$i', channel: 'dm', minute: i), NotifyKind.direct),
        ],
        channels: {
          'dm': NotifyChannel(
            id: 'dm',
            type: 'D',
            lastViewedAt: _t0.add(const Duration(minutes: 2)),
          ),
        },
        cursor: _t0,
        notified: const {},
        collapsedThreads: false,
        maxMessages: 5,
      );
      expect(updates.single.posts.map((p) => p.id), [
        'p6',
        'p7',
        'p8',
        'p9',
        'p10',
      ]);
    });

    test('collapsed-thread replies get a notification per thread', () {
      final updates = conversationUpdates(
        notifiable: [
          (_post('root-post', channel: 'dm', minute: 1), NotifyKind.direct),
          (
            _post('reply', channel: 'dm', minute: 2, rootId: 'root-post'),
            NotifyKind.thread,
          ),
        ],
        channels: channels,
        cursor: _t0,
        notified: const {},
        collapsedThreads: true,
      );
      expect(updates.map((u) => u.key), [
        const ConversationKey('dm'),
        const ConversationKey('dm', 'root-post'),
      ]);
      expect(updates.last.kind, NotifyKind.thread);
    });

    test('the most important kind names the conversation', () {
      final updates = conversationUpdates(
        notifiable: [
          (_post('a', minute: 1), NotifyKind.other),
          (_post('b', minute: 2, message: '@kim'), NotifyKind.direct),
        ],
        channels: {'town': _open},
        cursor: _t0,
        notified: const {},
        collapsedThreads: false,
      );
      expect(updates.single.kind, NotifyKind.direct);
    });

    test('the remembered ids stay bounded, newest kept', () {
      final update = ConversationUpdate(
        key: const ConversationKey('dm'),
        kind: NotifyKind.direct,
        posts: [_post('x'), _post('y')],
      );
      expect(rememberNotified(['a', 'b', 'c'], [update], keep: 3), [
        'c',
        'x',
        'y',
      ]);
      expect(rememberNotified(['x'], [update]), ['x', 'y']);
    });
  });

  group('clearing', () {
    final shown = [
      ShownConversation(
        serverUrl: 'https://chat.example.com',
        key: const ConversationKey('dm'),
        newestAt: _t0,
      ),
      ShownConversation(
        serverUrl: 'https://chat.example.com',
        key: const ConversationKey('town', 'root'),
        newestAt: _t0,
      ),
    ];

    test('a channel read at or after its newest message is cleared', () {
      expect(
        readSince(
          shown,
          channelsViewedAt: {'dm': _t0, 'town': _t0},
        ).map((s) => s.key),
        [const ConversationKey('dm'), const ConversationKey('town', 'root')],
      );
      expect(
        readSince(
          shown,
          channelsViewedAt: {'dm': _t0.subtract(const Duration(seconds: 1))},
        ),
        isEmpty,
      );
    });

    test('a thread follows its own read time over the channel', () {
      expect(
        readSince(
          shown,
          channelsViewedAt: {'town': _t0},
          threadsViewedAt: {'root': _t0.subtract(const Duration(minutes: 1))},
        ).map((s) => s.key),
        isEmpty,
      );
    });
  });

  group('payload', () {
    test('round-trips and refuses what is not ours', () {
      final target = NoticeTarget(
        serverUrl: 'https://chat.example.com',
        channelId: 'c1',
        rootId: 'r1',
        postId: 'p1',
        teamId: 't1',
        newestAt: _t0,
      );
      final back = NoticeTarget.decode(target.encode())!;
      expect(
        (
          back.serverUrl,
          back.channelId,
          back.rootId,
          back.postId,
          back.newestAt,
        ),
        ('https://chat.example.com', 'c1', 'r1', 'p1', _t0),
      );
      expect(NoticeTarget.decode('not json'), isNull);
      expect(NoticeTarget.decode('{"s": 1}'), isNull);
      expect(NoticeTarget.decode(null), isNull);
    });

    test('ids are stable and differ per conversation', () {
      final a = Notifier.idOf(
        Notifier.tagOf('https://a.example', const ConversationKey('c')),
      );
      expect(
        a,
        Notifier.idOf(
          Notifier.tagOf('https://a.example', const ConversationKey('c')),
        ),
      );
      expect(
        a,
        isNot(
          Notifier.idOf(
            Notifier.tagOf('https://b.example', const ConversationKey('c')),
          ),
        ),
      );
    });
  });
}

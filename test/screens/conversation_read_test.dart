import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/conversation_read.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/ui/anchored_list.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/wait.dart';

Map<String, Object?> postJson(String id, int minute, {String rootId = ''}) => {
  'id': id,
  'channel_id': channelId,
  'root_id': rootId,
  'user_id': 'someone',
  'create_at': DateTime.utc(2026, 10, 25, 10, minute).millisecondsSinceEpoch,
  'message': 'message $id',
};

/// When an open conversation counts as read, as in the official app.
void main() {
  test('the new-messages text names the count and when they began', () {
    final now = DateTime(2026, 10, 29, 16);
    expect(
      newMessagesText(1, DateTime(2026, 10, 29, 14, 5), now, use24: true),
      '1 new message since 14:05',
    );
    expect(
      newMessagesText(12, DateTime(2026, 10, 28, 14, 5), now, use24: true),
      '12 new messages since yesterday at 14:05',
    );
    expect(newMessagesText(3, null, now, use24: true), '3 new messages');
  });

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // The binding answers every HTTP request with 400; this talks to the fake
  // server for real.
  HttpOverrides.global = null;

  late FakeServer server;
  late ServerSession session;
  late ProviderContainer container;

  setUp(() async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    (server, session) = await startServerSession();
    server.handle = (r) {
      if (r.path == '/api/v4/posts/root1/thread') {
        return ok({
          'order': ['reply1', 'root1'],
          'posts': {
            'root1': postJson('root1', 0),
            'reply1': postJson('reply1', 1, rootId: 'root1'),
          },
        });
      }
      if (r.path.endsWith('/channels/$channelId/posts')) {
        return ok({'order': <String>[], 'posts': <String, Object?>{}});
      }
      if (r.path.endsWith('/users/ids')) return ok(<Object?>[]);
      return ok({'status': 'OK'});
    };
    container = ProviderContainer(
      overrides: [
        serverSessionProvider(server.url.toString())
            .overrideWith((ref) async => session),
      ],
    );
    addTearDown(container.dispose);
  });

  int requests(String path) => server.paths.where((p) => p == path).length;

  /// Opens the conversation; [atBottom] has its list report the newest
  /// message in view, as a short one does.
  Future<void> open({String? rootId, bool atBottom = false}) async {
    final provider = conversationProvider(
      server.url.toString(),
      channelId,
      rootId: rootId,
    );
    container.listen(provider, (_, _) {});
    await eventually(() {
      final s = container.read(provider);
      return s.window != null && !s.refreshing;
    });
    if (atBottom) {
      container
          .read(provider.notifier)
          .onView(
            const AnchoredListView(
              pinned: true,
              nearOlderEnd: false,
              newestVisible: 0,
              oldestVisible: 0,
            ),
          );
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  group('a thread under collapsed threads', () {
    const read = '/api/v4/users/me/teams/$teamId/threads/root1/read';
    bool readAsked() => server.paths.any((p) => p.startsWith('$read/'));

    setUp(() async {
      await session.store.applyConfig(ConfigKeys.clientConfig, {
        'CollapsedThreads': 'always_on',
      });
    });

    test('one I don\'t follow is not marked read', () async {
      await open(rootId: 'root1');
      expect(readAsked(), isFalse);
    });

    test('one I follow is marked read on opening', () async {
      await session.store.applyThreads(teamId, [
        api.UserThread.fromJson({
          'id': 'root1',
          'reply_count': 1,
          'unread_replies': 1,
          'is_following': true,
          'post': postJson('root1', 0),
        }),
      ]);
      await open(rootId: 'root1', atBottom: true);
      expect(readAsked(), isTrue);
    });
  });

  group('reading follows what the reader can see', () {
    const view = '/api/v4/channels/members/me/view';
    const posts = '/api/v4/channels/$channelId/posts';
    final atBottom = const AnchoredListView(
      pinned: true,
      nearOlderEnd: false,
      newestVisible: 0,
      oldestVisible: 5,
    );
    final scrolledUp = const AnchoredListView(
      pinned: false,
      nearOlderEnd: false,
      newestVisible: 8,
      oldestVisible: 12,
    );

    int views() => requests(view);

    Future<void> postFromSomeone(int n) async {
      await session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': 'posted',
            'data': {'post': jsonEncode(postJson('q$n', 20 + n))},
            'broadcast': {'channel_id': channelId},
            'seq': 1,
          }),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    test(
      'what the opening refresh fetches is read after it, not before',
      () async {
        final answer = Completer<void>();
        server.handle = (r) async {
          if (r.path == posts) {
            await answer.future;
            return ok({
              'order': ['fresh1'],
              'posts': {'fresh1': postJson('fresh1', 30)},
            });
          }
          if (r.path.endsWith('/users/ids')) return ok(<Object?>[]);
          return ok({'status': 'OK'});
        };
        final provider = conversationProvider(server.url.toString(), channelId);
        container.listen(provider, (_, _) {});
        await eventually(() => container.read(provider).window != null);
        container.read(provider.notifier).onView(atBottom);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(views(), 0);
        answer.complete();
        await eventually(() => views() == 1);
        final order = server.paths.toList();
        expect(order.indexOf(view), greaterThan(order.indexOf(posts)));
      },
    );

    test('what the reader reached while the window had no focus is read when '
        'the focus returns', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        DesktopShell.windowFocused = true;
      });
      DesktopShell.windowFocused = false;
      final provider = conversationProvider(server.url.toString(), channelId);
      container.listen(provider, (_, _) {});
      container.read(provider.notifier).onView(atBottom);
      await eventually(() {
        final s = container.read(provider);
        return s.window != null && !s.refreshing;
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(views(), 0);
      DesktopShell.windowFocused = true;
      await eventually(() => views() == 1);
    });

    test('a reader scrolled up leaves new messages unread until they reach '
        'the newest one', () async {
      final provider = conversationProvider(server.url.toString(), channelId);
      container.listen(provider, (_, _) {});
      container.read(provider.notifier).onView(scrolledUp);
      await eventually(() {
        final s = container.read(provider);
        return s.window != null && !s.refreshing;
      });
      await postFromSomeone(1);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(views(), 0);

      container.read(provider.notifier).onView(atBottom);
      await eventually(() => views() == 1);
    });

    test('a reader who scrolls down through newer pages to the newest message '
        'has read the channel', () async {
      final base = DateTime.utc(2026, 10, 26, 8).millisecondsSinceEpoch;
      Map<String, Object?> at(int i) => {
        ...postJson('n$i', 0),
        'create_at': base + i * 60000,
      };
      Map<String, Object?> page(Iterable<int> newestFirst) => {
        'order': [for (final i in newestFirst) 'n$i'],
        'posts': {for (final i in newestFirst) 'n$i': at(i)},
      };
      Iterable<int> range(int newest, int oldest) => [
        for (var i = newest; i >= oldest; i--) i,
      ];
      server.handle = (r) {
        if (r.path == '/api/v4/posts/n50') return ok(at(50));
        if (r.path == posts) {
          final query = r.raw.uri.queryParameters;
          if (query.containsKey('since')) {
            return ok(page(range(1300, 301)));
          }
          if (query['before'] == 'n50') return ok(page(range(49, 20)));
          if (query['after'] == 'n50') return ok(page(range(110, 51)));
          if (query['after'] == 'n110') return ok(page(range(150, 111)));
          return ok(page(range(200, 141)));
        }
        if (r.path.endsWith('/users/ids')) return ok(<Object?>[]);
        return ok({'status': 'OK'});
      };
      final provider = conversationProvider(
        server.url.toString(),
        channelId,
        highlightPostId: 'n50',
      );
      container.listen(provider, (_, _) {});
      container.read(provider.notifier).onView(scrolledUp);
      await eventually(() {
        final s = container.read(provider);
        return s.window != null && !s.refreshing;
      });
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(container.read(provider).window?.newerApart, isTrue);
      expect(views(), 0);
      container.read(provider.notifier).onView(atBottom);
      await eventually(
        () => container.read(provider).window?.newerApart == false,
      );
      await eventually(() => views() == 1);
    });

    test(
      'a message arriving while the reader is at the bottom is read',
      () async {
        await open();
        final provider = conversationProvider(server.url.toString(), channelId);
        container.read(provider.notifier).onView(atBottom);
        await eventually(() => views() == 1);
        await postFromSomeone(2);
        await eventually(() => views() == 2);
      },
    );
  });

  group('an open channel', () {
    const view = '/api/v4/channels/members/me/view';
    var minute = 10;

    Future<void> postFromSomeone() async {
      await session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({
            'event': 'posted',
            'data': {'post': jsonEncode(postJson('p${minute++}', minute))},
            'broadcast': {'channel_id': channelId},
            'seq': 1,
          }),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    test('is read again when a new message arrives', () async {
      await open(atBottom: true);
      expect(requests(view), 1);
      await postFromSomeone();
      await eventually(() => requests(view) == 2);
    });

    test('marked unread stays unread when a new message arrives', () async {
      await open(atBottom: true);
      await session.store.applyMarkedUnread(
        api.ChannelMember.fromJson({
          'channel_id': channelId,
          'user_id': meId,
          'msg_count': 0,
        }),
      );
      await postFromSomeone();
      expect(requests(view), 1);
    });
  });
}

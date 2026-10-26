import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';

ChannelInput channel(
  String id, {
  String type = 'O',
  String? name,
  String? displayName,
  bool archived = false,
  int total = 10,
  int read = 10,
  int totalRoot = 10,
  int readRoot = 10,
  int mentions = 0,
  int mentionsRoot = 0,
  bool muted = false,
  int lastPost = 0,
  int? lastViewed = 1,
}) => (
  id: id,
  type: type,
  name: name ?? id,
  displayName: displayName ?? id,
  archived: archived,
  createAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
  lastPostAt: DateTime.fromMillisecondsSinceEpoch(lastPost, isUtc: true),
  lastRootPostAt: DateTime.fromMillisecondsSinceEpoch(lastPost, isUtc: true),
  totalMsgCount: total,
  totalMsgCountRoot: totalRoot,
  msgCount: read,
  msgCountRoot: readRoot,
  mentionCount: mentions,
  mentionCountRoot: mentionsRoot,
  muted: muted,
  lastViewedAt: lastViewed == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(lastViewed, isUtc: true),
);

CategoryInput category(
  String id, {
  String type = 'custom',
  String sorting = '',
  bool collapsed = false,
}) => (
  id: id,
  type: type,
  displayName: id,
  sorting: sorting,
  collapsed: collapsed,
);

PersonInput person(String username, {String status = 'offline'}) => (
  username: username,
  firstName: '',
  lastName: '',
  nickname: '',
  status: status,
);

ChannelList build(
  List<ChannelInput> channels, {
  List<CategoryInput>? categories,
  Map<String, List<String>>? members,
  Map<String, PersonInput> people = const {},
  Map<String, int> pictureUpdates = const {},
  Set<String> hiddenDirect = const {},
  Set<String> hiddenGroups = const {},
  bool crt = false,
}) {
  final cats = categories ?? [category('all')];
  return buildChannelList(
    ChannelListSource(
      myId: 'me',
      teamName: 'Team',
      categories: cats,
      channelIdsByCategory:
          members ??
          {
            cats.first.id: [for (final c in channels) c.id],
          },
      channels: {for (final c in channels) c.id: c},
      people: people,
      pictureUpdates: pictureUpdates,
      hiddenDirect: hiddenDirect,
      hiddenGroups: hiddenGroups,
      collapsedThreads: crt,
    ),
  );
}

List<String> titles(ChannelList list, [int section = 0]) => [
  for (final r in list.sections[section].rows) r.title,
];

void main() {
  group('rows', () {
    test('a direct message shows the other person\'s current picture', () {
      final list = build(
        [
          channel('d1', type: 'D', name: 'me__bob'),
          channel('g1', type: 'G', displayName: 'alice, bob, carol'),
        ],
        people: {'me': person('alice'), 'bob': person('bob')},
        pictureUpdates: {'bob': 1700000000000},
      );
      final rows = {for (final r in list.sections.single.rows) r.id: r};
      expect(rows['d1']!.userId, 'bob');
      expect(rows['d1']!.pictureUpdate, 1700000000000);
      expect(rows['g1']!.userId, isNull, reason: 'groups keep their count');
    });

    test('unread is the counter difference; muted only shows mentions', () {
      final list = build([
        channel('quiet'),
        channel('news', read: 7),
        channel('muted', read: 2, muted: true),
        channel('muted-mention', read: 2, muted: true, mentions: 3),
      ]);
      final rows = {for (final r in list.sections.single.rows) r.id: r};
      expect(rows['quiet']!.unread, isFalse);
      expect(rows['news']!.unread, isTrue);
      expect(rows['muted']!.unread, isFalse);
      expect(rows['muted-mention']!.mentions, 3);
      expect(rows['muted-mention']!.muted, isTrue);
    });

    test('with collapsed threads only root posts count', () {
      final list = build([channel('replies', read: 5, mentions: 2)], crt: true);
      final row = list.sections.single.rows.single;
      expect(row.unread, isFalse);
      expect(row.mentions, 0);
      expect(list.unreadThreads, 0);
    });

    test('direct messages are named after the partner, with presence', () {
      final list = build(
        [
          channel('d1', type: 'D', name: 'me__bob'),
          channel('d2', type: 'D', name: 'me__me'),
          channel('g1', type: 'G', displayName: 'alice, bob, carol'),
        ],
        people: {
          'bob': person('bob', status: 'away'),
          'me': person('alice'),
        },
      );
      final rows = {for (final r in list.sections.single.rows) r.id: r};
      expect(rows['d1']!.title, 'bob');
      expect(rows['d1']!.status, 'away');
      expect(rows['d2']!.title, 'alice (you)');
      expect(rows['g1']!.title, 'bob, carol');
      expect(rows['g1']!.others, 2);
    });

    test('archived and closed conversations are hidden unless unread', () {
      final list = build(
        [
          channel('old', archived: true),
          channel('closed', type: 'D', name: 'me__bob'),
          channel('closed-unread', type: 'D', name: 'me__carol', read: 1),
          channel('group', type: 'G', displayName: 'a, b'),
        ],
        hiddenDirect: {'bob', 'carol'},
        hiddenGroups: {'group'},
      );
      expect(
        [for (final r in list.sections.single.rows) r.id],
        ['closed-unread'],
      );
    });
  });

  group('categories', () {
    final channels = [
      channel('b-chan', lastPost: 300),
      channel('a-chan', lastPost: 100),
      channel('c-chan', lastPost: 200, muted: true),
      channel('ch 10', lastPost: 0),
      channel('ch 2', lastPost: 0),
    ];

    test('alphabetical puts muted last and compares numbers', () {
      final list = build(channels);
      expect(titles(list), ['a-chan', 'b-chan', 'ch 2', 'ch 10', 'c-chan']);
    });

    test('recent sorts by the last post, manual keeps the order', () {
      expect(
        titles(build(channels, categories: [category('r', sorting: 'recent')])),
        ['b-chan', 'c-chan', 'a-chan', 'ch 10', 'ch 2'],
      );
      expect(
        titles(build(channels, categories: [category('m', sorting: 'manual')])),
        ['b-chan', 'a-chan', 'c-chan', 'ch 10', 'ch 2'],
      );
    });

    test('collapsed categories keep only unread rows', () {
      final list = build(
        [
          channel('read'),
          channel('unread', read: 1),
          channel('mention', mentions: 1),
        ],
        categories: [category('c', collapsed: true)],
      );
      final section = list.sections.single;
      expect([for (final r in section.shown) r.title], ['mention', 'unread']);
      expect(section.collapsed, isTrue);
      expect(titles(list), [
        'mention',
        'read',
        'unread',
      ], reason: 'reordering still sees every channel');
    });

    test('an empty favourites category is left out, favourites are marked', () {
      final list = build(
        [channel('x')],
        categories: [
          category('fav', type: 'favorites'),
          category('chan', type: 'channels'),
        ],
        members: {
          'fav': [],
          'chan': ['x'],
        },
      );
      expect(list.sections.map((s) => s.kind), [CategoryKind.channels]);
      final starred = build(
        [channel('x')],
        categories: [category('fav', type: 'favorites')],
      );
      expect(starred.sections.single.rows.single.favorite, isTrue);
    });
  });

  test('rows hold their places while the reader is away from the top', () {
    ChannelItem item(String id, {bool unread = false}) => ChannelItem(
      id: id,
      title: id,
      kind: ChannelKind.public,
      unread: unread,
      mentions: 0,
      muted: false,
      favorite: false,
      hasDraft: false,
    );
    CategorySection section(List<ChannelItem> rows) => CategorySection(
      id: 's',
      title: 's',
      kind: CategoryKind.channels,
      collapsed: false,
      rows: rows,
    );
    final shown = [
      section([item('a'), item('b'), item('c')]),
    ];
    final fresh = [
      section([item('c', unread: true), item('a'), item('new')]),
    ];
    final kept = keepOrder(fresh, shown).single.rows;
    expect(kept.map((r) => r.id), ['a', 'c', 'new']);
    expect(kept[1].unread, isTrue);
  });

  test('team badges come from channels once they were fetched', () {
    expect(
      teamBadge(
        channelsSynced: false,
        channelMentions: 0,
        anyChannelUnread: false,
        teamMentions: 4,
        teamUnreadMessages: 9,
      ),
      (unread: true, mentions: 4),
    );
    expect(
      teamBadge(
        channelsSynced: true,
        channelMentions: 1,
        anyChannelUnread: false,
        teamMentions: 4,
        teamUnreadMessages: 9,
      ),
      (unread: false, mentions: 1),
    );
  });

  test('the unreads filter shows only channels with something new, in one '
      'section, and nothing when all is read', () {
    final list = build([
      channel('quiet'),
      channel('busy', total: 12),
      channel('called', mentions: 2),
      channel('hushed', total: 12, muted: true),
    ]);
    final filtered = unreadsOnly(list.sections);
    expect(filtered, hasLength(1));
    expect(filtered.single.title, 'Unreads');
    expect(filtered.single.shown.map((r) => r.id), ['busy', 'called']);
    expect(unreadsOnly(build([channel('quiet')]).sections), isEmpty);
  });

  group('pane state', () {
    final stored = build([channel('x')]);
    const never = ChannelList(
      teamName: 'T',
      sections: [],
      unreadThreads: null,
      drafts: 0,
      synced: false,
    );
    ChannelListState stateOf(ChannelList? list, SyncStatus? status) =>
        channelListState(
          list: list,
          status: status,
          serverName: 'Harbour',
          host: 'chat.example.test',
        );
    final offline = SyncFailed(
      cause: const Unreachable(),
      at: DateTime.utc(2026),
    );
    final broken = SyncFailed(
      cause: const ServerError(statusCode: 500),
      at: DateTime.utc(2026),
    );

    test('nothing stored: a spinner, or the failure with its cause', () {
      expect(stateOf(null, null), isA<ChannelListLoading>());
      expect(
        stateOf(never, const SyncRefreshing(running: 1, queued: 0)),
        isA<ChannelListLoading>(),
      );
      final failed = stateOf(never, offline) as ChannelListFailed;
      expect(failed.title, "Couldn't load channels for Harbour");
      expect(failed.detail, isNotEmpty);
    });

    test('stored data stays, refreshing or with a quiet notice', () {
      final refreshing = stateOf(
        stored,
        const SyncRefreshing(running: 1, queued: 0),
      ) as ChannelListReady;
      expect(refreshing.refreshing, isTrue);
      expect(refreshing.notice, isNull);
      expect(
        (stateOf(stored, offline) as ChannelListReady).notice,
        'Offline · showing saved data',
      );
      expect(
        (stateOf(stored, broken) as ChannelListReady).notice,
        "Couldn't update: server error 500",
      );
    });

    test('live updates down for a while say so, unless a refresh failed', () {
      ChannelListState down(SyncStatus? status) => channelListState(
        list: stored,
        status: status,
        serverName: 'Harbour',
        host: 'chat.example.test',
        liveUpdatesDown: true,
      );
      expect(
        (down(const SyncIdle()) as ChannelListReady).notice,
        'Reconnecting…',
      );
      expect(
        (down(offline) as ChannelListReady).notice,
        'Offline · showing saved data',
      );
      expect(
        (stateOf(stored, const SyncIdle()) as ChannelListReady).notice,
        isNull,
      );
    });

    test('a synced team without channels is ready and empty', () {
      final empty = never.copyWith(synced: true);
      final state = stateOf(empty, const SyncIdle()) as ChannelListReady;
      expect(state.list.isEmpty, isTrue);
    });
  });

  group('auto-closing direct messages', () {
    ({String id, bool unread, DateTime? lastViewed, bool current}) dm(
      String id, {
      bool unread = false,
      int? viewed,
      bool current = false,
    }) => (
      id: id,
      unread: unread,
      lastViewed: viewed == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(viewed, isUtc: true),
      current: current,
    );

    test('the most recently viewed read ones fill the limit', () {
      expect(
        autoCloseDirect([
          dm('old', viewed: 1),
          dm('newer', viewed: 3),
          dm('newest', viewed: 5),
          dm('never'),
        ], limit: 2),
        {'newer', 'newest'},
      );
    });

    test('unread and open ones always stay, even past the limit', () {
      expect(
        autoCloseDirect([
          dm('u1', unread: true),
          dm('u2', unread: true),
          dm('open', current: true),
          dm('read', viewed: 9),
        ], limit: 1),
        {'u1', 'u2', 'open'},
      );
    });

    test('a channel list keeps 20 read conversations by default', () {
      final dms = [
        for (var i = 0; i < 25; i++)
          channel('d$i', type: 'D', name: 'u${i}__me', lastViewed: i + 1),
      ];
      final list = build(
        dms,
        categories: [category('dms', type: 'direct_messages')],
      );
      final ids = list.sections.single.rows.map((r) => r.id).toSet();
      expect(ids, hasLength(defaultDirectLimit));
      expect(ids, isNot(contains('d0')));
      expect(ids, contains('d24'));
    });
  });
}

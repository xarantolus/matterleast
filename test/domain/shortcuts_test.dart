import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/domain/quick_switch.dart';

void main() {
  const server = 'https://chat.example.test';
  SwitchItem item(String id, SwitchKind kind, int? viewedMinute) => SwitchItem(
    serverUrl: server,
    kind: kind,
    id: id,
    title: id,
    lastViewedAt: viewedMinute == null
        ? null
        : DateTime.utc(2026, 10, 25, 9, viewedMinute),
  );

  test('the launcher offers the conversations viewed last, newest first', () {
    final recent = recentConversations([
      item('boats', SwitchKind.channel, 1),
      item('bob', SwitchKind.direct, 5),
      item('never-opened', SwitchKind.channel, null),
      item('carol', SwitchKind.person, 9),
      item('crew', SwitchKind.privateChannel, 3),
      item('old', SwitchKind.archived, 8),
      item('bob-carol', SwitchKind.group, 4),
      item('docks', SwitchKind.channel, 2),
    ]);
    expect(
      [for (final i in recent) i.id],
      ['bob', 'bob-carol', 'crew', 'docks', 'boats'],
    );
    expect(
      [for (final i in recent.take(4)) i.id],
      ['bob', 'bob-carol', 'crew', 'docks'],
    );
  });

  test(
    'conversations of every server rank together, muted ones not at all',
    () {
      const other = 'https://other.example.test';
      final recent = recentConversations([
        item('boats', SwitchKind.channel, 1),
        item('quiet', SwitchKind.channel, 9).copyWith(muted: true),
        item('bob', SwitchKind.direct, 5).copyWith(serverUrl: other),
      ], count: 2);
      expect(
        [for (final i in recent) shortcutType(i)],
        ['$other\nbob', '$server\nboats'],
      );
    },
  );

  test('a share or launch id names a conversation of a signed-in server', () {
    final boats = item('boats', SwitchKind.channel, 1);
    SwitchItem? find(String? id, {Set<String> signedIn = const {server}}) =>
        shortcutItem(id, signedIn: signedIn, items: [boats]);
    expect(find(shortcutType(boats)), boats);
    expect(find(shortcutType(boats), signedIn: {}), isNull);
    expect(find('$server\ngone'), isNull);
    expect(find('garbage'), isNull);
    expect(find(null), isNull);
  });

  test('shortcuts of a signed-out server or a left channel are withdrawn', () {
    const other = 'https://other.example.test';
    final boats = item('boats', SwitchKind.channel, 1);
    final quiet = item('quiet', SwitchKind.channel, 2).copyWith(muted: true);
    final stale = shortcutsToRemove(
      {
        shortcutType(boats),
        shortcutType(quiet),
        '$server\nleft',
        '$other\nbob',
        'junk',
      },
      signedIn: {server},
      loaded: {server},
      items: [boats, quiet],
    );
    expect(stale, {'$server\nleft', '$other\nbob', 'junk'});
  });

  test('a server whose conversations have not arrived keeps its shortcuts', () {
    final stale = shortcutsToRemove(
      {'$server\nboats'},
      signedIn: {server},
      loaded: {},
      items: [],
    );
    expect(stale, isEmpty);
  });

  test('a shortcut names its server and channel', () {
    final type = shortcutType(item('boats', SwitchKind.channel, 1));
    expect(parseShortcutType(type), (url: server, channelId: 'boats'));
    expect(parseShortcutType('something else'), isNull);
    expect(parseShortcutType('\nboats'), isNull);
  });
}

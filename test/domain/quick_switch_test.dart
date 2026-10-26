import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/quick_switch.dart';

SwitchItem item(
  String title, {
  SwitchKind kind = SwitchKind.channel,
  List<String> keys = const [],
  DateTime? viewed,
  bool unread = false,
  int mentions = 0,
  bool muted = false,
  String? id,
  String? userId,
  String server = 'https://chat.example.test',
}) => SwitchItem(
  serverUrl: server,
  kind: kind,
  id: id ?? title,
  title: title,
  keys: keys,
  lastViewedAt: viewed,
  unread: unread,
  mentions: mentions,
  muted: muted,
  userId: userId,
);

List<String> titles(List<SwitchItem> items) => [for (final i in items) i.title];

void main() {
  group('a typed term finds', () {
    final items = [
      item('Town Square'),
      item('Garden Club'),
      item('Release Planning'),
      item('quarterly-review', keys: ['Quarterly Review']),
      item('Off-Topic'),
    ];

    test('names starting with it, then words, inside, letters in order', () {
      expect(titles(rankSwitchItems('re', items)), [
        'Release Planning',
        'quarterly-review',
        'Town Square',
        'Garden Club',
      ]);
    });

    test('partial words anywhere in the name', () {
      expect(titles(rankSwitchItems('plan', items)), ['Release Planning']);
      expect(titles(rankSwitchItems('quare', items)).first, 'Town Square');
    });

    test('names with one typo', () {
      expect(titles(rankSwitchItems('gradne', items)), isEmpty);
      expect(titles(rankSwitchItems('gaden', items)), ['Garden Club']);
      expect(titles(rankSwitchItems('relaese', items)), ['Release Planning']);
    });

    test('letters in order as a last resort', () {
      expect(titles(rankSwitchItems('tsq', items)), ['Town Square']);
    });

    test('nothing for a blank term or unrelated letters', () {
      expect(rankSwitchItems('  ', items), isEmpty);
      expect(rankSwitchItems('zzz', items), isEmpty);
    });

    test('regardless of a leading # or ~', () {
      expect(titles(rankSwitchItems('~town', items)), ['Town Square']);
    });
  });

  test('joined conversations come before people and archived channels', () {
    final items = [
      item('Alex Archive', kind: SwitchKind.archived),
      item('Alex Moreau', kind: SwitchKind.person),
      item('alex-team', kind: SwitchKind.channel),
    ];
    expect(titles(rankSwitchItems('alex', items)), [
      'alex-team',
      'Alex Moreau',
      'Alex Archive',
    ]);
  });

  test('a better match beats a joined channel', () {
    final items = [
      item('the-mill', kind: SwitchKind.channel),
      item('Millie Brook', kind: SwitchKind.person),
    ];
    expect(titles(rankSwitchItems('millie', items)), ['Millie Brook']);
  });

  test('equal matches show the most recently viewed first', () {
    final items = [
      item('design-a', viewed: DateTime.utc(2026, 1, 1)),
      item('design-b', viewed: DateTime.utc(2026, 3, 1)),
      item('design-c'),
    ];
    expect(titles(rankSwitchItems('design', items)), [
      'design-b',
      'design-a',
      'design-c',
    ]);
  });

  test('a leading @ only finds people', () {
    final items = [
      item('sam-chat'),
      item('Sam Ortiz', kind: SwitchKind.person, keys: ['sortiz']),
      item('Sam Lee', kind: SwitchKind.direct, keys: ['slee']),
    ];
    expect(titles(rankSwitchItems('@sam', items)), ['Sam Lee', 'Sam Ortiz']);
    expect(titles(rankSwitchItems('@sortiz', items)), ['Sam Ortiz']);
  });

  test('server answers already shown locally are left out', () {
    final local = [
      item('garden', id: 'c1'),
      item('Gary Holt', kind: SwitchKind.direct, id: 'd1', userId: 'u1'),
    ];
    final remote = [
      item('garden', id: 'c1', kind: SwitchKind.joinable),
      item('garage', id: 'c2', kind: SwitchKind.joinable),
      item('Gary Holt', id: 'u1', kind: SwitchKind.person),
      item('Gabe Stone', id: 'u2', kind: SwitchKind.person),
    ];
    expect(titles(extraRemoteItems('ga', local, remote)), [
      'Gabe Stone',
      'garage',
    ]);
  });

  test('the start view lists unread first, then recent ones', () {
    final items = [
      item('quiet', viewed: DateTime.utc(2026, 5, 1)),
      item('busy', unread: true, viewed: DateTime.utc(2026, 4, 1)),
      item('pinged', mentions: 2, viewed: DateTime.utc(2026, 2, 1)),
      item(
        'muted',
        unread: true,
        muted: true,
        viewed: DateTime.utc(2026, 6, 1),
      ),
      item('never-opened'),
      item('stranger', kind: SwitchKind.person, unread: true),
    ];
    final start = switchStart(items);
    expect(titles(start.unread), ['pinged', 'busy']);
    expect(titles(start.recent), ['muted', 'quiet']);
  });

  test('a picker starts with the most recently used, then all by name', () {
    final items = [
      item('zeta'),
      item('Alpha'),
      item(
        'posted',
        kind: SwitchKind.group,
      ).copyWith(lastPostAt: DateTime.utc(2026, 10, 26, 9)),
      item('older', viewed: DateTime.utc(2026, 10, 20)),
      item(
        'newest',
        viewed: DateTime.utc(2026, 10, 25),
        kind: SwitchKind.direct,
      ),
    ];
    final start = pickerStart(items, recentLimit: 2);
    expect(titles(start.recent), ['newest', 'older']);
    expect(titles(start.rest), ['Alpha', 'posted', 'zeta']);
    expect(titles(pickerStart(items).recent), ['newest', 'older', 'posted']);
  });
}

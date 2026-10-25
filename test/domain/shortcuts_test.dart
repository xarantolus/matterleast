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

  test('the launcher offers the four conversations viewed last', () {
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
      ['bob', 'bob-carol', 'crew', 'docks'],
    );
  });

  test('a shortcut names its server and channel', () {
    final type = shortcutType(item('boats', SwitchKind.channel, 1));
    expect(parseShortcutType(type), (url: server, channelId: 'boats'));
    expect(parseShortcutType('something else'), isNull);
    expect(parseShortcutType('\nboats'), isNull);
  });
}

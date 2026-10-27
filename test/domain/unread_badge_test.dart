import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/unread_badge.dart';

RailTeam team(int mentions, {bool unread = true}) => RailTeam(
  id: 't$mentions',
  displayName: 'Team',
  unread: unread,
  mentions: mentions,
);

InboxItem row(InboxKind kind, int count) => InboxItem(
  serverUrl: 'https://chat.example.test',
  kind: kind,
  channelId: '${kind.name}$count',
  teamId: null,
  title: 'Someone',
  avatarName: 'Someone',
  author: null,
  preview: 'hello',
  place: null,
  time: DateTime.utc(2026, 3),
  count: count,
  unread: true,
);

void main() {
  test('team mentions and unread direct and group messages count', () {
    expect(
      unreadMentions(
        teams: [team(2), team(0)],
        unread: [
          row(InboxKind.direct, 3),
          row(InboxKind.group, 1),
          // A reply in a followed thread is in the team's mentions already
          // when it mentions; plain replies don't count.
          row(InboxKind.thread, 5),
        ],
      ),
      6,
    );
    expect(unreadMentions(teams: [team(0)], unread: const []), 0);
  });

  test('a dot on the tray and the number on the taskbar, 9+ above 9', () {
    expect(windowBadge(0), (dot: false, overlay: 0));
    expect(windowBadge(1), (dot: true, overlay: 1));
    expect(windowBadge(9), (dot: true, overlay: 9));
    expect(windowBadge(10), (dot: true, overlay: 10));
    expect(windowBadge(250), (dot: true, overlay: 10));
  });

  group('the taskbar flashes', () {
    test('when a mention or message arrives in the background', () {
      expect(flashesTaskbar(before: 0, now: 1, focused: false), isTrue);
      expect(flashesTaskbar(before: 4, now: 5, focused: false), isTrue);
    });

    test('not while the window is focused', () {
      expect(flashesTaskbar(before: 0, now: 1, focused: true), isFalse);
    });

    test('not for the first count after launch', () {
      expect(flashesTaskbar(before: null, now: 3, focused: false), isFalse);
    });

    test('not when messages were read or nothing changed', () {
      expect(flashesTaskbar(before: 3, now: 1, focused: false), isFalse);
      expect(flashesTaskbar(before: 3, now: 3, focused: false), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/autocomplete.dart';

void main() {
  group('what the cursor asks for', () {
    Trigger? at(String text) => triggerAt(text, text.length);

    test('@ after a space or at the start asks for people', () {
      expect(
        at('hi @ma'),
        isA<UserTrigger>().having((t) => t.prefix, 'p', 'ma'),
      );
      expect(at('@'), isA<UserTrigger>().having((t) => t.start, 'start', 0));
    });

    test('an address is not a mention', () {
      expect(at('mail river@harbour'), isNull);
    });

    test('a finished word closes the list', () {
      expect(at('hi @mara '), isNull);
    });

    test('~ asks for channels', () {
      expect(at('see ~bo'), isA<ChannelTrigger>());
    });

    test('emoji need two characters, like the official app', () {
      expect(at('nice :t'), isNull);
      expect(
        at('nice :th'),
        isA<EmojiTrigger>()
            .having((t) => t.prefix, 'p', 'th')
            .having((t) => t.start, 'start', 5),
      );
      expect(at('+:th'), isA<EmojiTrigger>());
      expect(at('time 10:30'), isNull);
    });

    test('a slash asks for commands only at the start', () {
      expect(
        at('/ec'),
        isA<CommandTrigger>().having((t) => t.prefix, 'p', 'ec'),
      );
      expect((at('/echo hel') as CommandTrigger).hasArguments, isTrue);
      expect(at('and/or'), isNull);
    });

    test('only the text before the cursor counts', () {
      expect(triggerAt('@mara and more', 3), isA<UserTrigger>());
      expect(triggerAt('@mara and more', 10), isNull);
    });
  });

  group('picking a suggestion', () {
    test('replaces the word and adds a space', () {
      const text = 'hi @ma';
      final trigger = triggerAt(text, text.length)!;
      final done = applySuggestion(text, text.length, trigger, '@mara');
      expect(done.text, 'hi @mara ');
      expect(done.cursor, 9);
    });

    test('keeps the text after the cursor', () {
      const text = 'hi @ma, see you';
      final trigger = triggerAt(text, 6)!;
      final done = applySuggestion(text, 6, trigger, '@mara');
      expect(done.text, 'hi @mara , see you');
      expect(done.cursor, 9);
    });

    test('does not double a following space', () {
      const text = ':th today';
      final trigger = triggerAt(text, 3)!;
      final done = applySuggestion(text, 3, trigger, '👍');
      expect(done.text, '👍 today');
      expect(done.cursor, '👍 '.length);
    });
  });

  group('people', () {
    UserCandidate user(
      String id,
      String username, {
      String first = '',
      String last = '',
      String nick = '',
      bool? inChannel,
    }) => (
      id: id,
      username: username,
      firstName: first,
      lastName: last,
      nickname: nick,
      inChannel: inChannel,
    );

    test('username matches lead, then names; outsiders come last', () {
      final ranked = rankUsers('ma', [
        user('1', 'zed', first: 'Mara'),
        user('2', 'marco', inChannel: false),
        user('3', 'mabel'),
        user('4', 'otto'),
      ]);
      expect(
        [for (final s in ranked) s.replacement],
        ['@mabel', '@zed', '@marco'],
      );
      expect((ranked.last as UserSuggestion).outOfChannel, isTrue);
    });

    test('special mentions follow the channel members', () {
      final ranked = rankUsers('a', [user('1', 'ada')]);
      expect([for (final s in ranked) s.replacement], ['@ada', '@all']);
      expect(rankUsers('', const []).length, 3);
      expect(rankUsers('h', const []).single, isA<SpecialMention>());
    });

    test('a last name or a word of the nickname matches', () {
      expect(
        rankUsers('sto', [user('1', 'r1', last: 'Stone')]).first.replacement,
        '@r1',
      );
      expect(
        rankUsers('cap', [user('1', 'r1', nick: 'the captain')]).length,
        1,
      );
    });
  });

  test('channels: own ones first, by name or a word of the display name, '
      'never direct messages', () {
    ChannelCandidate channel(
      String id,
      String name,
      String display, {
      String type = 'O',
      bool member = true,
    }) =>
        (id: id, name: name, displayName: display, type: type, member: member);
    final ranked = rankChannels('bo', [
      channel('1', 'boats', 'Boats', member: false),
      channel('2', 'old-harbour', 'Harbour boats'),
      channel('3', 'bo__dm', 'bo', type: 'D'),
      channel('4', 'docks', 'Docks'),
    ]);
    expect([for (final c in ranked) c.replacement], ['~old-harbour', '~boats']);
    expect(ranked.last.member, isFalse);
  });

  test('emoji: recent ones first, then by name start, then later words', () {
    final ranked = rankEmoji(
      'sm',
      systemNames: ['smile', 'smiley', 'grinning_smile', 'heart', 'smirk'],
      customNames: ['smugcat'],
      recent: ['smirk', 'heart'],
      unicodeOf: (name) => 'U($name)',
    );
    expect(
      [for (final e in ranked) e.name],
      ['smirk', 'smile', 'smiley', 'smugcat', 'grinning_smile'],
    );
    expect(ranked.first.replacement, 'U(smirk)');
    expect(ranked[3].replacement, ':smugcat:');
  });

  test('commands match the start of their trigger', () {
    final ranked = rankCommands('e', [
      (trigger: 'echo', hint: 'text', description: 'Echo', iconUrl: ''),
      (trigger: 'away', hint: '', description: '', iconUrl: ''),
      (trigger: 'expand', hint: '', description: '', iconUrl: ''),
    ]);
    expect([for (final c in ranked) c.replacement], ['/echo', '/expand']);
  });

  test('recent emoji keep the newest first without repeats', () {
    expect(withRecentEmoji(['a', 'b'], ['b', 'c'], limit: 3), ['c', 'b', 'a']);
  });
}

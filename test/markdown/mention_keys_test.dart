import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/markdown/mention_keys.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';

/// What is marked in [text], as the words themselves.
List<String> _marked(
  String text, {
  List<MentionKey> mentions = const [],
  List<String> highlights = const [],
}) => [
  for (final r in highlightRanges(
    text,
    MentionKeys(mentions: mentions, highlights: highlights),
  ))
    text.substring(r.start, r.end),
];

MentionKey _key(String key, {bool exact = false}) =>
    MentionKey(key, caseSensitive: exact);

void main() {
  group('mention words', () {
    final cases = <String, (String, List<MentionKey>, List<String>)>{
      'no words': ('apple banana orange', [], []),
      'one word': ('apple banana orange', [_key('banana')], ['banana']),
      'every occurrence': (
        'apple banana apple',
        [_key('apple')],
        ['apple', 'apple'],
      ),
      'capitals do not matter': (
        'Apple APPLE',
        [_key('apple')],
        ['Apple', 'APPLE'],
      ),
      'capitals matter when asked': (
        'apple APPLE Apple aPPle',
        [_key('Apple', exact: true)],
        ['Apple'],
      ),
      'before a full stop': ('banana.', [_key('banana')], ['banana']),
      'before underscores': ('banana__', [_key('banana')], ['banana']),
      'in brackets': ('(banana)', [_key('banana')], ['banana']),
      'after punctuation': (':banana', [_key('banana')], ['banana']),
      'not inside another word': ('pineapple', [_key('apple')], []),
      'not followed by letters': ('applesauce', [_key('apple')], []),
      'odd characters are literal': ('apple', [_key(r'*\3_.')], []),
      'a blank word is nothing': ('apple', [_key('')], []),
      'korean has no word edges': ('좋은 하루 되세요.', [_key('하루')], ['하루']),
      'korean inside a word': ('좋은하루되세요', [_key('하루')], ['하루']),
      'japanese inside a sentence': ('今日は東京です', [_key('東京')], ['東京']),
      'cyrillic inside a word': ('приветмир', [_key('мир')], ['мир']),
      'thai inside a word': ('สวัสดีครับ', [_key('ครับ')], ['ครับ']),
      'a key with an at sign': ('call @pat now', [_key('@pat')], ['@pat']),
    };
    for (final MapEntry(key: name, value: (text, keys, expected))
        in cases.entries) {
      test(name, () => expect(_marked(text, mentions: keys), expected));
    }
  });

  group('highlight words', () {
    test('are found in any case', () {
      expect(_marked('Lol. lol', highlights: ['LOL']), ['Lol', 'lol']);
    });

    test('keep to word edges', () {
      expect(_marked('lollipop ?lol? lol_', highlights: ['lol']), [
        'lol',
        'lol',
      ]);
    });

    test('a longer word wins over a shorter one inside it', () {
      final ranges = highlightRanges(
        'good morning',
        const MentionKeys(highlights: ['good', 'good morning']),
      );
      expect(ranges.map((r) => (r.start, r.end)), [(0, 12)]);
    });

    test('never mark what a mention word already marks', () {
      final ranges = highlightRanges(
        'ship it',
        const MentionKeys(
          mentions: [MentionKey('ship')],
          highlights: ['ship', 'it'],
        ),
      );
      expect(ranges.map((r) => (r.kind, r.start)), [
        (Highlight.mention, 0),
        (Highlight.keyword, 5),
      ]);
    });
  });

  group('the words of a user', () {
    test('are their mention words, first name with capitals and @username', () {
      final keys = MentionKeys.forUser(
        username: 'river',
        firstName: 'Rivka',
        props: const NotifyProps({
          'mention_keys': 'river, deploy ,',
          'first_name': 'true',
          'highlight_keys': ' fika ,,',
          'channel': 'true',
        }),
      );
      expect(keys.mentions, [
        const MentionKey('river'),
        const MentionKey('deploy'),
        const MentionKey('Rivka', caseSensitive: true),
        const MentionKey('@river'),
      ]);
      expect(keys.highlights, ['fika']);
      expect(keys.broadcast, isTrue);
    });

    test('have no highlight words when the server stored none', () {
      final keys = MentionKeys.forUser(
        username: 'river',
        firstName: '',
        props: const NotifyProps({'channel': 'false'}),
      );
      expect(keys.highlights, isEmpty);
      expect(keys.broadcast, isFalse);
    });

    test('a typed @name may end in a full stop of the sentence', () {
      const keys = MentionKeys(mentions: [MentionKey('@bob')]);
      expect(keys.mentionsName('bob.'), isTrue);
      expect(keys.mentionsName('Bob'), isTrue);
      expect(keys.mentionsName('bob.smith'), isFalse);
      expect(
        const MentionKeys(mentions: [MentionKey('@bob_')]).mentionsName('bob_'),
        isTrue,
      );
    });
  });

  group('in a message', () {
    const options = ParseOptions(
      mentions: MentionKeys(
        mentions: [MentionKey('deploy'), MentionKey('@river')],
        highlights: ['fika'],
      ),
    );
    List<Inline> line(String text) =>
        ((parsePost(text, options) as ParsedPost).blocks.single as Paragraph)
            .inlines;

    test('words are split out of the text', () {
      expect(line('before the deploy, fika?'), [
        const Inline.text('before the '),
        const Inline.text('deploy', highlight: Highlight.mention),
        const Inline.text(', '),
        const Inline.text('fika', highlight: Highlight.keyword),
        const Inline.text('?'),
      ]);
    });

    test('keep their bold', () {
      expect(line('**deploy now**'), [
        const Inline.text(
          'deploy',
          marks: Marks.bold,
          highlight: Highlight.mention,
        ),
        const Inline.text(' now', marks: Marks.bold),
      ]);
    });

    test('code and links are left alone', () {
      expect(line('`deploy` [deploy](https://x.example.test)'), [
        const Inline.code('deploy'),
        const Inline.text(' '),
        const Inline.text('deploy', link: 'https://x.example.test'),
      ]);
    });

    test('an @mention of the user is marked as theirs', () {
      expect(
        line('@river and @sam').whereType<MentionPart>().map((m) => m.mine),
        [true, false],
      );
    });
  });
}

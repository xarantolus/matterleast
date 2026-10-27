import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/markdown/spoken_post.dart';

SpokenPost _spoken(String text, {Map<String, String> channels = const {}}) =>
    spokenPost(
      parsePost(text, const ParseOptions()),
      unicode: unicodeForName,
      channelNames: channels,
    );

void main() {
  test('markup goes, the words stay, one line per block', () {
    expect(
      _spoken('# Notes\n\n**Bold** and `code`\n\n> quoted\n\n- one\n- two')
          .text,
      'Notes\nBold and code\nquoted\none\ntwo',
    );
  });

  test('emoji become their character or their name in words', () {
    expect(_spoken('nice :tada: :party_parrot:').text, 'nice 🎉 party parrot');
  });

  test('tasks say whether they are done', () {
    expect(
      _spoken('- [x] sails\n- [ ] ropes').text,
      'Done: sails\nNot done: ropes',
    );
  });

  test('links, mentions and channels are listed once each, special '
      'mentions not at all', () {
    final spoken = _spoken(
      '@kit @Kit @here see [the table](https://example.test/t) and '
      '[the table](https://example.test/t) in ~boats',
      channels: {'boats': 'Boats'},
    );
    expect(
      spoken.text,
      '@kit @Kit @here see the table and the table in ~Boats',
    );
    expect(
      [
        for (final t in spoken.targets)
          switch (t) {
            SpokenLink(:final text, :final url) => '$text $url',
            SpokenMention(:final name) => '@$name',
            SpokenChannel(:final name, :final shown) => '~$name $shown',
          },
      ],
      ['@kit', 'the table https://example.test/t', '~boats Boats'],
    );
  });

  test('an integration button in the text is flagged, not offered as a '
      'link', () {
    final spoken = _spoken('[Approve](mmaction://approve?id=1)');
    expect(spoken.inlineActions, isTrue);
    expect(spoken.targets, isEmpty);
  });
}

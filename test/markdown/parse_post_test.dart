import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';

const _plain = ParseOptions();

List<Block> _blocks(String text, [ParseOptions options = _plain]) =>
    (parsePost(text, options) as ParsedPost).blocks;

List<Inline> _line(String text, [ParseOptions options = _plain]) =>
    (_blocks(text, options).single as Paragraph).inlines;

void main() {
  group('mentions', () {
    test('a trailing full stop stays part of the typed name', () {
      expect(_line('ask @bob.'), [
        const Inline.text('ask '),
        const Inline.mention('bob.'),
      ]);
    });

    test('an address-like word is not a mention', () {
      expect(_line('me@alice'), [const Inline.text('me@alice')]);
    });

    test('special mentions are mentions', () {
      expect(_line('@here').single, const Inline.mention('here'));
    });

    test('a mention inside a link label is link text', () {
      expect(
        _line('[@alice](https://x.test)').single,
        const Inline.text('@alice', link: 'https://x.test'),
      );
    });
  });

  group('channel links and strikethrough', () {
    test('two tildes strike through, one starts a channel link', () {
      expect(_line('~~old~~ in ~town-square'), [
        const Inline.text('old', marks: Marks.strike),
        const Inline.text(' in '),
        const Inline.channel('town-square'),
      ]);
    });

    test('unsafe posts show channel links and hashtags as text', () {
      expect(_line('~design #release', const ParseOptions(unsafeLinks: true)), [
        const Inline.text('~design #release'),
      ]);
    });
  });

  group('emoji', () {
    test('names are kept even when unknown', () {
      expect(
        _line(':no-such-emoji:').single,
        const Inline.emoji('no-such-emoji', ':no-such-emoji:'),
      );
    });

    test('emoticons at the start of a line become emoji', () {
      expect(
        _line(':) fine').first,
        const Inline.emoji('slightly_smiling_face', ':)'),
      );
    });

    test('an emoticon inside a word stays text', () {
      expect(_line('a:)b'), [const Inline.text('a:)b')]);
    });

    test('a name glued to a word stays text', () {
      expect(_line('1:tada:'), [const Inline.text('1:tada:')]);
    });
  });

  group('hashtags', () {
    test('shorter than the minimum stays text', () {
      expect(_line('#ab #abc'), [
        const Inline.text('#ab '),
        const Inline.hashtag('abc'),
      ]);
    });

    test('the minimum comes from the server', () {
      expect(
        _line('#ab', const ParseOptions(minimumHashtagLength: 2)).single,
        const Inline.hashtag('ab'),
      );
    });

    test('a heading of a hashtag is a heading whose text is the tag', () {
      expect(
        _blocks('# #SomeTitle').single,
        const Block.heading(1, [Inline.hashtag('SomeTitle')]),
      );
    });

    test('a trailing full stop is not part of the tag', () {
      expect(_line('#release.').first, const Inline.hashtag('release'));
    });
  });

  group('LaTeX', () {
    const latex = ParseOptions(latexInline: true, latexBlocks: true);

    test(r'two prices are not a formula', () {
      expect(_line(r'$5 and $6', latex), [const Inline.text(r'$5 and $6')]);
    });

    test('inline formulas only when the server allows them', () {
      expect(_line(r'is $x^2$ ok', latex)[1], const Inline.math('x^2'));
      expect(_line(r'is $x^2$ ok'), [const Inline.text(r'is $x^2$ ok')]);
    });

    test('a latex fence is a formula block only when allowed', () {
      expect(
        _blocks('```latex\nx^2\n```', latex).single,
        const Block.math('x^2'),
      );
      expect(
        _blocks('```latex\nx^2\n```').single,
        const Block.code('x^2', language: 'latex'),
      );
    });
  });

  group('links', () {
    test('trailing punctuation is left out of a bare link', () {
      expect(
        _line('see https://x.test/a?, then')[1],
        const Inline.text('https://x.test/a', link: 'https://x.test/a'),
      );
    });

    test('balanced parentheses stay in a bare link', () {
      const url = 'https://x.test/wiki/Lamp_(device)';
      expect(_line('($url)')[1], const Inline.text(url, link: url));
    });

    test('www links get a scheme', () {
      expect(
        _line('www.x.test').single,
        const Inline.text('www.x.test', link: 'http://www.x.test'),
      );
    });

    test('bare email addresses become mail links', () {
      expect(
        _line('to crew@x.test').last,
        const Inline.text('crew@x.test', link: 'mailto:crew@x.test'),
      );
    });

    test('unsafe posts show links as text', () {
      expect(
        _line('[a](https://x.test)', const ParseOptions(unsafeLinks: true)),
        [const Inline.text('a')],
      );
    });
  });

  group('images', () {
    test('a size after the address is read', () {
      expect(
        _line('![a](https://x.test/a.png =50x76)').single,
        const Inline.image(
          'https://x.test/a.png',
          alt: 'a',
          width: 50,
          height: 76,
        ),
      );
    });

    test('a height alone is read', () {
      expect(
        _line('![a](https://x.test/a.png =x20)').single,
        const Inline.image('https://x.test/a.png', alt: 'a', height: 20),
      );
    });
  });

  group('blocks', () {
    test('HTML is shown as written', () {
      expect(_line('<b>hi</b>'), [const Inline.text('<b>hi</b>')]);
    });

    test('a fence keeps its language and text', () {
      expect(
        _blocks('```dart\nmain() {}\n```').single,
        const Block.code('main() {}', language: 'dart'),
      );
    });

    test('task items are checked only with a lowercase x', () {
      final list = _blocks('- [ ] a\n- [x] b\n- [X] c').single as ListBlock;
      expect([for (final i in list.items) i.checked], [false, true, null]);
      expect(
        list.items.first.blocks.single,
        const Block.paragraph([Inline.text('a')]),
      );
    });

    test('ordered lists keep their first number', () {
      final list = _blocks('3. a\n4. b').single as ListBlock;
      expect((list.ordered, list.start, list.items.length), (true, 3, 2));
    });

    test('tables keep alignment and cells', () {
      final table =
          _blocks('| a | b |\n|:-:|--:|\n| 1 | 2 |').single as TableBlock;
      expect(table.align, [CellAlign.center, CellAlign.end]);
      expect(table.rows.length, 2);
      expect(table.rows[1][1], [const Inline.text('2')]);
    });

    test('headings keep their level', () {
      expect(
        _blocks('### Three').single,
        const Block.heading(3, [Inline.text('Three')]),
      );
    });
  });

  test('more nodes than the server allows is too long to show', () {
    final text = List.filled(50, '**a** ').join();
    expect(
      parsePost(text, const ParseOptions(maxNodes: 20)),
      const PostDoc.tooLong(),
    );
    expect(
      parsePost(text, const ParseOptions(maxNodes: 2000)),
      isA<ParsedPost>(),
    );
  });
}

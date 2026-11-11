import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/channel/composer_markdown.dart';

TextEditingValue _v(String text, [int? a, int? b]) => TextEditingValue(
  text: text,
  selection: TextSelection(
    baseOffset: a ?? text.length,
    extentOffset: b ?? a ?? text.length,
  ),
);

TextEditingValue _format(TextEditingValue old, TextEditingValue next) =>
    const ComposerMarkdown().formatEditUpdate(old, next);

/// Enter at the end of [text].
String _enter(String text) => _format(_v(text), _v('$text\n')).text;

void main() {
  group('lists continue', () {
    test('bullets, numbers, tasks and quotes', () {
      expect(_enter('- one'), '- one\n- ');
      expect(_enter('* one'), '* one\n* ');
      expect(_enter('1. one'), '1. one\n2. ');
      expect(_enter('9. one'), '9. one\n10. ');
      expect(_enter('- [x] one'), '- [x] one\n- [ ] ');
      expect(_enter('> one'), '> one\n> ');
      expect(_enter('  - one'), '  - one\n  - ');
    });

    test('an empty item ends the list', () {
      expect(_enter('- one\n- '), '- one\n');
      expect(_enter('1. '), '');
    });

    test('plain lines, code fences and IME text are left alone', () {
      expect(_enter('one'), 'one\n');
      expect(_enter('```\n- one'), '```\n- one\n');
      final composing = _v('- one\n')
          .copyWith(composing: const TextRange(start: 0, end: 3));
      expect(_format(_v('- one'), composing).text, '- one\n');
    });

    test('the text after the caret moves to the new item', () {
      final out = _format(_v('- ab', 3), _v('- a\nb', 4));
      expect(out.text, '- a\n- b');
      expect(out.selection.baseOffset, 6);
    });
  });

  group('typing over a selection wraps it', () {
    final old = _v('see the docs now', 8, 12);

    test('and keeps the inner text selected', () {
      final out = _format(old, _v('see the * now', 9));
      expect(out.text, 'see the *docs* now');
      expect(
        out.selection,
        const TextSelection(baseOffset: 9, extentOffset: 13),
      );
    });

    test('brackets and quotes close', () {
      expect(_format(old, _v('see the ( now', 9)).text, 'see the (docs) now');
      expect(_format(old, _v('see the [ now', 9)).text, 'see the [docs] now');
      expect(_format(old, _v('see the " now', 9)).text, 'see the "docs" now');
      expect(_format(old, _v('see the ` now', 9)).text, 'see the `docs` now');
    });

    test('other characters, a caret and code blocks replace as usual', () {
      expect(_format(old, _v('see the x now', 9)).text, 'see the x now');
      expect(_format(_v('see', 3), _v('see*', 4)).text, 'see*');
      expect(_format(_v('```\nabc', 4, 7), _v('```\n*', 5)).text, '```\n*');
    });
  });

  group('pasted spreadsheet rows', () {
    test('make a table with the first row as header', () {
      final out = _format(_v(''), _v('a\tb\n1\t2\n3\t4\n'));
      expect(out.text, '| a | b |\n| --- | --- |\n| 1 | 2 |\n| 3 | 4 |');
      expect(out.selection.baseOffset, out.text.length);
    });

    test('escape pipes and start on a new line', () {
      final out = _format(_v('see'), _v('seea|b\tc\r\n1\t2'));
      expect(out.text, 'see\n| a\\|b | c |\n| --- | --- |\n| 1 | 2 |');
    });

    test('ragged rows, one row and plain text stay text', () {
      expect(_format(_v(''), _v('a\tb\n1')).text, 'a\tb\n1');
      expect(_format(_v(''), _v('a\tb')).text, 'a\tb');
      expect(_format(_v(''), _v('a\nb')).text, 'a\nb');
      expect(_format(_v(''), _v('\tx = 1\n\ty = 2')).text, '\tx = 1\n\ty = 2');
    });
  });

  group('indenting list items', () {
    test('indents by the marker width and back', () {
      final out = indentListItems(_v('- one', 3))!;
      expect(out.text, '  - one');
      expect(out.selection.baseOffset, 5);
      expect(indentListItems(out, outdent: true)!.text, '- one');
      expect(indentListItems(_v('1. one', 4))!.text, '   1. one');
      expect(indentListItems(_v('- one'), outdent: true)!.text, '- one');
    });

    test('every selected line moves', () {
      final out = indentListItems(_v('- a\n- b\nx', 0, 7))!;
      expect(out.text, '  - a\n  - b\nx');
      expect(
        out.selection,
        const TextSelection(baseOffset: 2, extentOffset: 11),
      );
    });

    test('lines that are not list items are not touched', () {
      expect(indentListItems(_v('plain', 2)), isNull);
      expect(onListItems(_v('- a\nplain', 0, 7)), isFalse);
      expect(onListItems(_v('- a', 1)), isTrue);
    });
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/text_wrap.dart';

TextEditingValue _value(String text, int base, [int? extent]) =>
    TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent ?? base),
    );

void main() {
  group('toggleWrap', () {
    final cases = <(String, TextEditingValue, String, TextEditingValue)>[
      (
        'wraps the selection and keeps it selected',
        _value('say hello now', 4, 9),
        '**',
        _value('say **hello** now', 6, 11),
      ),
      (
        'inserts a pair at the cursor and puts the cursor between',
        _value('ab', 1),
        '_',
        _value('a__b', 2),
      ),
      (
        'without any selection information it goes to the end',
        const TextEditingValue(text: 'ab'),
        '~~',
        _value('ab~~~~', 4),
      ),
      (
        'unwraps markers just outside the selection',
        _value('say **hello** now', 6, 11),
        '**',
        _value('say hello now', 4, 9),
      ),
      (
        'unwraps markers inside the selection',
        _value('say **hello** now', 4, 13),
        '**',
        _value('say hello now', 4, 9),
      ),
      (
        'a single marker character selected is wrapped, not unwrapped',
        _value('a*b', 1, 2),
        '**',
        _value('a*****b', 3, 4),
      ),
      (
        'italic is not confused with bold around the selection',
        _value('**hello**', 2, 7),
        '_',
        _value('**_hello_**', 3, 8),
      ),
      (
        'a reversed selection wraps the same',
        _value('hello', 5, 0),
        '~~',
        _value('~~hello~~', 2, 7),
      ),
    ];
    for (final (name, before, marker, after) in cases) {
      test(name, () {
        final result = toggleWrap(before, marker);
        expect(result.text, after.text);
        expect(result.selection, after.selection);
      });
    }

    test('twice is the text it started with', () {
      final start = _value('say hello now', 4, 9);
      final twice = toggleWrap(toggleWrap(start, '**'), '**');
      expect(twice.text, start.text);
      expect(twice.selection, start.selection);
    });
  });

  group('insertLink', () {
    test('makes the selection the label and selects the url', () {
      final result = insertLink(_value('see docs now', 4, 8));
      expect(result.text, 'see [docs](url) now');
      expect(result.selection.textInside(result.text), 'url');
    });

    test('without a selection puts the cursor in the label', () {
      final result = insertLink(_value('ab', 1));
      expect(result.text, 'a[](url)b');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });
  });

  group('steppedHistory', () {
    final cases = <(String, int, int, bool, int)>[
      ('nothing to step through', 0, -1, true, -1),
      ('the newest first', 3, -1, true, 0),
      ('older again', 3, 0, true, 1),
      ('stops at the oldest', 3, 2, true, 2),
      ('newer', 3, 2, false, 1),
      ('back to what was typed', 3, 0, false, -1),
      ('newer than that stays', 3, -1, false, -1),
    ];
    for (final (name, count, at, older, expected) in cases) {
      test(
        name,
        () => expect(steppedHistory(count, at, older: older), expected),
      );
    }
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/channel/link_over_selection.dart';

TextEditingValue _v(String text, int a, int b) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: a, extentOffset: b),
);

void main() {
  final old = _v('see the docs now', 8, 12);

  test('a URL pasted over a word links it', () {
    final out = linkOverSelection(
      old,
      _v('see the https://a.example/x now', 26, 26),
    );
    expect(out?.text, 'see the [docs](https://a.example/x) now');
    expect(out?.selection, const TextSelection.collapsed(offset: 35));
  });

  test('whitespace around the URL is dropped', () {
    final out = linkOverSelection(old, _v('see the  http://a.b/ \n now', 8, 8));
    expect(out?.text, 'see the [docs](http://a.b/) now');
  });

  test('other pasted text is left alone', () {
    expect(linkOverSelection(old, _v('see the hello now', 13, 13)), isNull);
    expect(linkOverSelection(old, _v('see the a.example/x now', 8, 8)), isNull);
    expect(
      linkOverSelection(old, _v('see the https://a.b/ c now', 8, 8)),
      isNull,
    );
  });

  test('a collapsed selection is left alone', () {
    expect(
      linkOverSelection(_v('see ', 4, 4), _v('see https://a.b/', 4, 4)),
      isNull,
    );
  });

  test('typing over a selection is left alone', () {
    expect(linkOverSelection(old, _v('see the x now', 9, 9)), isNull);
  });

  test('a multi-line selection is left alone', () {
    expect(
      linkOverSelection(_v('a\nb', 0, 3), _v('https://a.b/', 12, 12)),
      isNull,
    );
  });
}

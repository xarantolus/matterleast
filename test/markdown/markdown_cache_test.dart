import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/markdown_cache.dart';
import 'package:matterleast/markdown/post_doc.dart';

void main() {
  late List<String> parsed;
  late MarkdownCache cache;

  setUp(() {
    parsed = [];
    cache = MarkdownCache(
      capacity: 2,
      parse: (text, _) {
        parsed.add(text);
        return PostDoc.plain(text);
      },
    );
  });

  const options = ParseOptions();

  test('a message is not parsed again while scrolling, only after an edit', () {
    cache.get('a', null, 'one', options);
    cache.get('a', null, 'one', options);
    cache.get('a', DateTime(2026), 'two', options);
    expect(parsed, ['one', 'two']);
  });

  test('other options parse again', () {
    cache.get('a', null, 'one', options);
    cache.get('a', null, 'one', const ParseOptions(latexInline: true));
    expect(parsed, ['one', 'one']);
  });

  test('the least recently used message is dropped first', () {
    cache.get('a', null, 'a', options);
    cache.get('b', null, 'b', options);
    cache.get('a', null, 'a', options);
    cache.get('c', null, 'c', options);
    cache.get('a', null, 'a', options);
    cache.get('b', null, 'b', options);
    expect(parsed, ['a', 'b', 'c', 'b']);
  });
}

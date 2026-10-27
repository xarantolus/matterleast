import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/preview_text.dart';

void main() {
  test('markers and emphasis go, the words stay on one line', () {
    expect(
      previewText(
        '# Release notes\n\n> **Bold**, *italic*, ~~gone~~ and `code`',
      ),
      'Release notes Bold, italic, gone and code',
    );
  });

  test('links and images leave their text', () {
    expect(
      previewText('See [the notes](https://example.test/n) ![chart](c.png)'),
      'See the notes chart',
    );
  });

  test('mentions, channels and words with underscores are kept', () {
    expect(
      previewText('@john_doe look at ~release_notes and _this_'),
      '@john_doe look at ~release_notes and this',
    );
  });

  test('list markers and code fences go, their content stays', () {
    expect(
      previewText('- [x] done\n- next\n```dart\nprint(1);\n```'),
      'done next print(1);',
    );
  });

  test('known emoji codes become the emoji, others and times stay', () {
    expect(
      previewText('this one is about you :smile: :party_parrot: at 10:30:45'),
      'this one is about you 😄 :party_parrot: at 10:30:45',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/attachment_card.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/show_more.dart';

void main() {
  group('image boxes', () {
    test('the measured size shrinks to the width, keeping the ratio', () {
      expect(
        imageBox(
          measuredWidth: 1600,
          measuredHeight: 800,
          maxWidth: 400,
          maxHeight: 1000,
        ),
        const Size(400, 200),
      );
    });

    test('a typed width keeps the measured ratio', () {
      expect(
        imageBox(
          measuredWidth: 100,
          measuredHeight: 50,
          width: 60,
          maxWidth: 400,
          maxHeight: 400,
        ),
        const Size(60, 30),
      );
    });

    test('tall images are capped by height', () {
      expect(
        imageBox(
          measuredWidth: 100,
          measuredHeight: 1000,
          maxWidth: 400,
          maxHeight: 300,
        ),
        const Size(30, 300),
      );
    });

    test('unknown sizes reserve nothing', () {
      expect(
        imageBox(
          measuredWidth: null,
          measuredHeight: null,
          maxWidth: 400,
          maxHeight: 300,
        ),
        isNull,
      );
    });
  });

  group('show more', () {
    test('a body up to half the screen plus the button stays whole', () {
      expect(collapsedHeight(400 + showMoreAllowance, 800), isNull);
    });

    test('a longer body is cut at half the screen', () {
      expect(collapsedHeight(400 + showMoreAllowance + 1, 800), 400);
    });
  });

  test('a message of only emoji is shown large, with text it is not', () {
    List<Block> blocks(String text) =>
        (parsePost(text, const ParseOptions()) as ParsedPost).blocks;
    expect(isJumbo(blocks(':tada: :+1:')), isTrue);
    expect(isJumbo(blocks(':tada: yes')), isFalse);
  });

  test('a trailing full stop after a mention is not part of the name', () {
    expect(mentionedUsername('bob.', {'bob'}), 'bob');
    expect(mentionedUsername('bob.smith', {'bob'}), isNull);
    expect(mentionedUsername('bob_', {'bob_'}), 'bob_');
  });

  test('attachment colours: hex, short hex and named', () {
    expect(attachmentColor('#ff0000'), const Color(0xFFFF0000));
    expect(attachmentColor('#0f0'), const Color(0xFF00FF00));
    expect(attachmentColor('danger'), const Color(0xFFE40303));
    expect(attachmentColor('nope'), isNull);
  });
}

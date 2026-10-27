import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/markdown/show_more.dart';

void main() {
  group('image boxes', () {
    test('the height cap is 45 % of the longer side in either orientation', () {
      expect(imageMaxHeight(const Size(400, 800)), 360);
      expect(imageMaxHeight(const Size(800, 400)), 360);
    });

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

  testWidgets('an image at an address no image comes from shows its alt '
      'text and is never fetched', (tester) async {
    final fetched = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse('https://chat.example.test'),
            options: const ParseOptions(),
            myUsername: 'river',
            onMention: (_) {},
            onChannel: (_) {},
            onLink: (_) {},
            image: (url, size, _) {
              fetched.add(url);
              return SizedBox.fromSize(size: size);
            },
            child: const Column(
              children: [
                MessageImage(
                  image: ImagePart('file:///etc/hosts', alt: 'a lighthouse'),
                  measured: ImageSize(width: 100, height: 50),
                ),
                MessageImage(
                  image: ImagePart('https://pics.example.test/boat.png'),
                  measured: ImageSize(width: 100, height: 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('a lighthouse'), findsOneWidget);
    expect(fetched, ['https://pics.example.test/boat.png']);
  });
}

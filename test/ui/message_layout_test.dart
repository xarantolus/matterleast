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
      expect(imageMaxHeight(const Size(400, 800), desktop: false), 360);
      expect(imageMaxHeight(const Size(800, 400), desktop: false), 360);
    });

    test('on desktop a preview fits 40 % of the window height and 60 % of '
        'the column', () {
      Size? box(Size window, double column, int w, int h) => imageBox(
        measuredWidth: w,
        measuredHeight: h,
        maxWidth: imageMaxWidth(column, desktop: true),
        maxHeight: imageMaxHeight(window, desktop: true),
      );
      const big = Size(1600, 1000);
      expect(box(big, 800, 2400, 1200), const Size(480, 240));
      expect(box(big, 800, 1200, 2400), const Size(200, 400));
      expect(box(big, 800, 200, 100), const Size(200, 100));
      const small = Size(1100, 700);
      expect(box(small, 500, 2400, 1200), const Size(300, 150));
      expect(box(small, 500, 1200, 2400), const Size(140, 280));
    });

    test('a video of unknown size is 16:9 within the same caps', () {
      const window = Size(1100, 700);
      final box = unmeasuredVideoBox(
        imageMaxWidth(900, desktop: true),
        imageMaxHeight(window, desktop: true),
      );
      expect(box.height, 280);
      expect(box.width, closeTo(280 * 16 / 9, 0.001));
      expect(unmeasuredVideoBox(300, 400), const Size(300, 168.75));
    });

    test('a tiny window keeps a floor so something still shows', () {
      expect(imageMaxHeight(const Size(600, 300), desktop: true), 160);
      expect(imageMaxWidth(200, desktop: true), 160);
      expect(imageMaxWidth(100, desktop: true), 100);
    });

    test('phones keep the full width and grids are smaller on desktop', () {
      expect(imageMaxWidth(900, desktop: false), 900);
      expect(gridMaxHeight(const Size(1600, 1000), desktop: true), 220);
      expect(gridMaxHeight(const Size(1100, 700), desktop: true), 154);
      expect(gridMaxHeight(const Size(400, 800), desktop: false), 360);
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

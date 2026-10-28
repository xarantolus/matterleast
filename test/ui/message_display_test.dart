import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/message_display.dart';

const _longLine =
    'final answer = computeTheAnswerToEverything(lifeTheUniverse, '
    'andEverythingElse, withExtraCareForTheLongestArgumentNames);';

Widget _app(
  Widget child, {
  double fontScale = 1,
  MessageTextSize size = MessageTextSize.normal,
  bool wrapCode = false,
  double width = 360,
}) => MaterialApp(
  theme: MatterleastApp.lightTheme,
  builder: (context, home) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(fontScale)),
    child: MessageDisplay(
      textScale: size.scale,
      wrapCode: wrapCode,
      child: home!,
    ),
  ),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(child: child),
      ),
    ),
  ),
);

Size _textSize(WidgetTester tester, String text) =>
    tester.getSize(find.textContaining(text, findRichText: true).first);

void main() {
  group('settings', () {
    test('text size and code wrapping are stored by name, unknown values '
        'fall back', () {
      final size = Settings.messageTextSize;
      expect(size.read(const {}), MessageTextSize.normal);
      expect(
        size.read({size.key: size.encode(MessageTextSize.larger)}),
        MessageTextSize.larger,
      );
      expect(size.read({size.key: 'gigantic'}), MessageTextSize.normal);
      final wrap = Settings.wrapCode;
      expect(wrap.read(const {}), isFalse);
      expect(wrap.read({wrap.key: wrap.encode(true)}), isTrue);
    });

    test('the sizes grow in order', () {
      final scales = [for (final s in MessageTextSize.values) s.scale];
      expect(scales, orderedEquals([...scales]..sort()));
      expect(MessageTextSize.normal.scale, 1);
    });
  });

  group('message text size', () {
    const message = 'Lunch is at noon in the **big** room';

    Future<double> heightAt(
      WidgetTester tester,
      MessageTextSize size, {
      double fontScale = 1,
    }) async {
      await tester.pumpWidget(
        _app(
          const PostBody(postId: 'p1', message: message),
          size: size,
          fontScale: fontScale,
          width: 2000,
        ),
      );
      return _textSize(tester, 'Lunch is at noon').height;
    }

    testWidgets('a larger setting makes message text larger, on top of the '
        "phone's font size", (tester) async {
      final normal = await heightAt(tester, MessageTextSize.normal);
      final small = await heightAt(tester, MessageTextSize.small);
      final larger = await heightAt(tester, MessageTextSize.larger);
      expect(small, lessThan(normal));
      expect(larger, greaterThan(normal));
      final phoneLarge = await heightAt(
        tester,
        MessageTextSize.normal,
        fontScale: 2,
      );
      final both = await heightAt(tester, MessageTextSize.larger, fontScale: 2);
      expect(both, greaterThan(phoneLarge));
    });

    testWidgets('a message holds together at font scale 2 with the largest '
        'setting on a narrow phone', (tester) async {
      await tester.pumpWidget(
        _app(
          const PostBody(
            postId: 'p2',
            message:
                '# Plans for the week\n\n'
                'Bring **snacks** :tada: and read https://docs.example.test/'
                'a/very/long/path/that/does/not/break/easily\n\n'
                '- [x] book the room\n- [ ] order lunch\n\n'
                '> quoted words from someone\n\n'
                '| Day | Dish |\n|---|---|\n| Mon | Soup |\n\n'
                '```dart\n$_longLine\nreturn answer;\n```',
            edited: true,
          ),
          size: MessageTextSize.larger,
          fontScale: 2,
          width: 320,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Plans for the week', findRichText: true), findsOne);
      expect(find.byTooltip('Wrap lines'), findsOneWidget);
    });
  });

  group('code blocks', () {
    Finder sideways() => find.ancestor(
      of: find.textContaining('computeTheAnswer', findRichText: true),
      matching: find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
    );

    testWidgets('a long line scrolls sideways until the block is wrapped, '
        'then it fits the width', (tester) async {
      await tester.pumpWidget(
        _app(const CodePreview(code: _longLine, language: 'dart'), width: 320),
      );
      expect(sideways(), findsOneWidget);
      final oneLine = _textSize(tester, 'computeTheAnswer');
      expect(oneLine.width, greaterThan(320));

      await tester.tap(find.byTooltip('Wrap lines'));
      await tester.pump();
      expect(sideways(), findsNothing);
      final wrapped = _textSize(tester, 'computeTheAnswer');
      expect(wrapped.width, lessThanOrEqualTo(320));
      expect(wrapped.height, greaterThan(oneLine.height * 2));

      await tester.tap(find.byTooltip("Don't wrap lines"));
      await tester.pump();
      expect(sideways(), findsOneWidget);
    });

    testWidgets('the wrap setting decides how blocks start', (tester) async {
      await tester.pumpWidget(
        _app(
          const CodePreview(code: _longLine, language: 'dart'),
          wrapCode: true,
          width: 320,
        ),
      );
      expect(sideways(), findsNothing);
      expect(find.byTooltip("Don't wrap lines"), findsOneWidget);
    });

    testWidgets('the whole block opens the way the preview showed it and '
        'switches on its own', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: _app(
            const CodePreview(code: '$_longLine\nreturn answer;', language: ''),
            width: 320,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Wrap lines'));
      await tester.pump();
      await tester.tap(
        find.textContaining('computeTheAnswer', findRichText: true),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CodeScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip("Don't wrap lines"),
        ),
        findsOneWidget,
      );
      // No line numbers when wrapped, since they would not line up.
      expect(find.text('1\n2'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip("Don't wrap lines"),
        ),
      );
      await tester.pump();
      expect(find.text('1\n2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

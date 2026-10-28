import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/screens/settings/display_settings_page.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/emoji_card.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/moment_tooltip.dart';

Widget _app(Widget child, {bool use24 = true}) => ProviderScope(
  child: MaterialApp(
    theme: themeForPlatform(MatterleastApp.lightTheme),
    builder: (context, home) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24),
      child: home!,
    ),
    home: Scaffold(
      body: PostEnvironment(
        server: Uri.parse('https://chat.example.test'),
        options: const ParseOptions(),
        myUsername: 'me',
        onMention: (_) {},
        onChannel: (_) {},
        onLink: (_) {},
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

Future<TestGesture> _hover(WidgetTester tester, Finder target) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(target));
  await tester.pump();
  return mouse;
}

MouseCursor? _cursor() =>
    RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1);

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

  group('on desktop', () {
    for (final (at, label) in [
      (DateTime(2026, 12, 31, 23, 59), 'Thursday, 31 December 2026 at 23:59'),
      (DateTime(2027, 1, 1, 0, 0), 'Friday, 1 January 2027 at 00:00'),
    ]) {
      testWidgets('hovering a time names $label', (tester) async {
        await tester.pumpWidget(
          _app(MomentTooltip(at: at, child: const Text('the time'))),
        );
        await _hover(tester, find.text('the time'));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text(label), findsOneWidget);
      }, variant: desktop);
    }

    testWidgets('a 12-hour clock names the time that way', (tester) async {
      await tester.pumpWidget(
        _app(
          MomentTooltip(
            at: DateTime(2026, 10, 27, 13, 5),
            prefix: 'Edited ',
            child: const Text('(edited)'),
          ),
          use24: false,
        ),
      );
      await _hover(tester, find.text('(edited)'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Edited Tuesday, 27 October 2026 at 1:05 PM'),
        findsOneWidget,
      );
    }, variant: desktop);

    testWidgets('a right click on a link only offers to copy it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const InlineText(
            inlines: [TextPart('the docs', link: 'https://docs.example.test')],
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
      final link = find.textContaining('the docs', findRichText: true);
      expect(link, findsOneWidget);
      await tester.tap(link, buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Open link'), findsNothing);
      expect(find.byType(PopupMenuItem<VoidCallback>), findsOneWidget);
    }, variant: desktop);

    testWidgets('a link shows the hand cursor', (tester) async {
      await tester.pumpWidget(
        _app(
          const InlineText(
            inlines: [TextPart('the docs', link: 'https://docs.example.test')],
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
      await _hover(tester, find.textContaining('the docs', findRichText: true));
      expect(_cursor(), SystemMouseCursors.click);
    }, variant: desktop);

    testWidgets('a plain gesture made clickable shows the hand, and none '
        'when disabled', (tester) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              Clickable(child: SizedBox.square(dimension: 40)),
              Clickable(
                enabled: false,
                child: SizedBox(width: 40, height: 40, key: Key('off')),
              ),
            ],
          ),
        ),
      );
      final mouse = await _hover(tester, find.byType(Clickable).first);
      expect(_cursor(), SystemMouseCursors.click);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('off'))));
      await tester.pump();
      expect(_cursor(), SystemMouseCursors.basic);
    }, variant: desktop);

    testWidgets('an icon button shows the hand through the desktop theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(IconButton(icon: const Icon(Icons.add), onPressed: () {})),
      );
      await _hover(tester, find.byType(IconButton));
      expect(_cursor(), SystemMouseCursors.click);
    }, variant: desktop);

    testWidgets('a long code block expands in place and copies', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      final code = [for (var i = 1; i <= 30; i++) 'line $i'].join('\n');
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: CodePreview(code: code, language: 'text'),
            ),
          ),
        ),
      );
      final block = find.byType(DesktopCodeBlock);
      final cut = tester.getSize(block).height;
      expect(find.textContaining('20 more lines'), findsOneWidget);

      await tester.tap(find.textContaining('Show more'));
      await tester.pumpAndSettle();
      expect(tester.getSize(block).height, greaterThan(cut * 2));
      expect(find.text('Show less'), findsOneWidget);
      // Still in the message, not a page of its own.
      expect(find.byType(CodeScreen), findsNothing);

      await tester.tap(find.byTooltip('Copy code'));
      await tester.pump();
      expect(copied, code);
    }, variant: desktop);

    testWidgets('the clock follows the "system setting", not the phone', (
      tester,
    ) async {
      final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: DisplaySettingsPage(server: null)),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(find.text('Use system setting'), findsOneWidget);
      expect(find.textContaining('phone'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await db.close();
    }, variant: desktop);
  });

  testWidgets('a tapped emoji in a message shows its name on a card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const InlineText(
          inlines: [TextPart('nice '), EmojiPart('tada', ':tada:')],
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
    await tester.tapOnText(find.textRange.ofSubstring('🎉'));
    await tester.pumpAndSettle();
    expect(find.byType(EmojiCard), findsOneWidget);
    expect(find.text(':tada:'), findsOneWidget);
  });
}

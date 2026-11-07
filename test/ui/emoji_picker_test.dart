import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/ui/emoji_picker.dart';

import '../support/pump_app.dart';

const _url = 'https://chat.example.test';

void main() {
  test('recent emoji come first, then custom, then the standard ones', () {
    final sections = emojiSections(recent: ['smile'], custom: ['partyblob']);
    expect([for (final s in sections) s.category].take(4), [
      'recent',
      'custom',
      'smileys-emotion',
      'people-body',
    ]);
    expect(sections.last.category, 'flags');
    expect(
      [for (final s in emojiSections(recent: [], custom: [])) s.category].first,
      'smileys-emotion',
    );
  });

  testWidgets('the category bar jumps to its section in one list', (
    tester,
  ) async {
    String? picked;
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                picked = await showEmojiPicker(context, _url),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: [
        recentEmojiProvider(_url).overrideWith((ref) async => ['smile']),
        customEmojiProvider(_url)
            .overrideWith((ref) => Stream.value(const <String, String>{})),
        customEmojiCatalogProvider(_url).overrideWith((ref) async {}),
        skinToneProvider(_url).overrideWith((ref) => Stream.value(0)),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('FLAGS'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Flags'));
    await tester.pumpAndSettle();
    expect(find.text('FLAGS'), findsOneWidget);
    expect(find.text('RECENT'), findsNothing);

    await tester.tap(find.text('\u{1F3C1}'));
    await tester.pumpAndSettle();
    expect(picked, 'checkered_flag');
  });

  group('on desktop', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

    Future<void> open(
      WidgetTester tester,
      ValueChanged<String?> onPicked, {
      ValueChanged<String>? onKeepOpen,
    }) async {
      await pumpApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => onPicked(
                await showEmojiPicker(context, _url, onKeepOpen: onKeepOpen),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        overrides: [
          recentEmojiProvider(_url).overrideWith((ref) async => const []),
          customEmojiProvider(_url)
              .overrideWith((ref) => Stream.value(const <String, String>{})),
          customEmojiCatalogProvider(_url).overrideWith((ref) async {}),
          skinToneProvider(_url).overrideWith((ref) => Stream.value(0)),
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('arrow keys move through the grid and Enter picks', (
      tester,
    ) async {
      String? picked;
      await open(tester, (name) => picked = name);
      // The search field has the focus; Down enters the grid on the first
      // emoji, Right and Down move on, Enter picks.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, namesInCategory('smileys-emotion')[1]);
    }, variant: desktop);

    testWidgets('a click with Shift held adds the emoji and keeps the '
        'picker open; a plain click closes it', (tester) async {
      final kept = <String>[];
      String? picked;
      await open(tester, (name) => picked = name, onKeepOpen: kept.add);
      final [first, second, ...] = namesInCategory('smileys-emotion');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.byTooltip(':$first:'));
      await tester.tap(find.byTooltip(':$second:'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(kept, [first, second]);
      expect(find.byType(EmojiPicker), findsOneWidget);

      await tester.tap(find.byTooltip(':$first:'));
      await tester.pumpAndSettle();
      expect(picked, first);
      expect(find.byType(EmojiPicker), findsNothing);
    }, variant: desktop);

    testWidgets('Up from the first row goes back to search; Esc closes', (
      tester,
    ) async {
      String? picked = 'unset';
      await open(tester, (name) => picked = name);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.enterText(find.byType(EditableText), 'smile');
      await tester.pump();
      expect(find.byType(EditableText), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(picked, isNull);
      expect(find.byType(EmojiPicker), findsNothing);
    }, variant: desktop);

    test('the cursor moves by cell and row, and stops at the edges', () {
      int? to(int from, LogicalKeyboardKey key) =>
          movedCell(from, key, columns: 5, count: 12);
      expect(to(0, LogicalKeyboardKey.arrowRight), 1);
      expect(to(0, LogicalKeyboardKey.arrowLeft), isNull);
      expect(to(7, LogicalKeyboardKey.arrowUp), 2);
      expect(to(7, LogicalKeyboardKey.arrowDown), isNull);
      expect(to(4, LogicalKeyboardKey.arrowRight), 5);
      expect(to(11, LogicalKeyboardKey.arrowRight), isNull);
    });
  });
}

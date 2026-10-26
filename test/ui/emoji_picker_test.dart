import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/ui/emoji_picker.dart';

const _url = 'https://chat.example.test';

void main() {
  test('custom emoji come first, then recent, then the standard ones', () {
    final sections = emojiSections(recent: ['smile'], custom: ['partyblob']);
    expect([for (final s in sections) s.category].take(4), [
      'custom',
      'recent',
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentEmojiProvider(_url).overrideWith((ref) async => ['smile']),
          customEmojiProvider(_url)
              .overrideWith((ref) => Stream.value(const <String, String>{})),
          customEmojiCatalogProvider(_url).overrideWith((ref) async {}),
          skinToneProvider(_url).overrideWith((ref) => Stream.value(0)),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    picked = await showEmojiPicker(context, _url),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
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
}

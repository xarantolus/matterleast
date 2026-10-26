import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/emoji/custom_emoji.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/custom_emoji_image.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';

const _url = 'https://chat.example.test';

/// The server's custom emoji are `partyblob` and `shipit`; it has none
/// called `nope`.
List<Override> _server({List<String> recent = const []}) => [
  customEmojiProvider(_url)
      .overrideWith((ref) => Stream.value({'partyblob': 'e1', 'shipit': 'e2'})),
  customEmojiMissingProvider(_url)
      .overrideWith((ref) => Stream.value({'nope'})),
  customEmojiResolverProvider(_url)
      .overrideWith((ref) => Completer<CustomEmojiResolver>().future),
  serverImageCachesProvider(_url)
      .overrideWith((ref) => Completer<ServerImageCaches>().future),
  recentEmojiProvider(_url).overrideWith((ref) async => recent),
];

Future<void> _show(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: _server(),
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Iterable<String> _customShown(WidgetTester tester) => tester
    .widgetList<CustomEmojiImage>(find.byType(CustomEmojiImage))
    .map((e) => e.emojiId);

void main() {
  testWidgets('a standard emoji is the system glyph in its square', (
    tester,
  ) async {
    await _show(
      tester,
      const EmojiGlyph(name: 'tada', size: 20, serverUrl: _url),
    );
    expect(find.text('🎉'), findsOneWidget);
    expect(tester.getSize(find.byType(EmojiGlyph)), const Size(20, 20));
  });

  testWidgets("a custom emoji shows the server's image in its square", (
    tester,
  ) async {
    await _show(
      tester,
      const EmojiGlyph(name: 'shipit', size: 20, serverUrl: _url),
    );
    expect(_customShown(tester), ['e2']);
    expect(tester.getSize(find.byType(EmojiGlyph)), const Size(20, 20));
  });

  testWidgets('a name the server does not know reads as the name', (
    tester,
  ) async {
    await _show(
      tester,
      const EmojiGlyph(name: 'nope', size: 20, serverUrl: _url),
    );
    expect(find.text(':nope:'), findsOneWidget);
  });

  testWidgets('a name still being looked up keeps its square empty', (
    tester,
  ) async {
    await _show(
      tester,
      const EmojiGlyph(name: 'brandnew', size: 20, serverUrl: _url),
    );
    expect(find.text(':brandnew:'), findsNothing);
    expect(find.byType(CustomEmojiImage), findsNothing);
    expect(tester.getSize(find.byType(EmojiGlyph)), const Size(20, 20));
  });

  testWidgets('the quick reactions show custom emoji used lately', (
    tester,
  ) async {
    final post = PostItem(
      id: 'post1',
      key: 'post1',
      userId: 'other',
      authorName: 'someone',
      createAt: DateTime.utc(2026, 3, 1),
      message: 'Hello',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._server(recent: ['partyblob', 'thumbsup']),
          postMenuFactsProvider(_url, post, 'team1').overrideWith(
            (ref) async => (
              myId: 'me',
              saved: false,
              following: false,
              teamName: '',
              rights: (
                react: true,
                reply: true,
                pin: true,
                edit: true,
                delete: true,
                markUnread: false,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showMessageMenu(
                  context,
                  url: _url,
                  teamId: 'team1',
                  post: post,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(_customShown(tester), ['e1']);
    expect(find.text(':partyblob:'), findsNothing);
  });

  testWidgets('a custom status shows its custom emoji', (tester) async {
    await _show(
      tester,
      const CustomStatusLine(
        url: _url,
        status: CustomStatus(emoji: 'partyblob', text: 'Launch day'),
      ),
    );
    expect(_customShown(tester), ['e1']);
    expect(find.textContaining('Launch day', findRichText: true), findsOne);
  });
}

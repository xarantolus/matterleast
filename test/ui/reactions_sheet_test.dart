import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/reactions_bar.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

void main() {
  testWidgets('who reacted names someone once their profile arrives', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '/api/v4/users/newcomer' => ok({
          'id': 'newcomer',
          'username': 'quinn',
          'first_name': 'Quinn',
        }),
        _ => ok(<String, Object?>{}),
      },
      home: (url) => Scaffold(
        body: PostEnvironment(
          server: Uri.parse(url),
          options: const ParseOptions(),
          myUsername: 'river',
          onMention: (_) {},
          onChannel: (_) {},
          onLink: (_) {},
          child: const ReactionsBar(
            reactions: [
              ReactionGroup(
                emojiName: 'tada',
                people: [
                  (
                    id: 'newcomer',
                    name: 'Someone',
                    username: '',
                    pictureAt: null,
                  ),
                ],
                mine: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(FilterChip));
    await h.settle(tester);
    expect(find.text('Someone'), findsNothing);
    expect(find.text('@quinn'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a held mouse button on a reaction shows nothing on desktop', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      handle: (r) => ok(<String, Object?>{}),
      home: (url) => const Scaffold(
        body: ReactionsBar(
          reactions: [
            ReactionGroup(
              emojiName: 'tada',
              people: [
                (id: 'a', name: 'Ada', username: 'ada', pictureAt: null),
              ],
              mine: false,
            ),
          ],
        ),
      ),
    );
    await tester.longPress(find.byType(FilterChip));
    await h.settle(tester);
    expect(find.text('Ada'), findsNothing);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('a held press on a reaction shows who reacted on a phone', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      handle: (r) => ok(<String, Object?>{}),
      home: (url) => const Scaffold(
        body: ReactionsBar(
          reactions: [
            ReactionGroup(
              emojiName: 'tada',
              people: [
                (id: 'a', name: 'Ada', username: 'ada', pictureAt: null),
              ],
              mine: false,
            ),
          ],
        ),
      ),
    );
    await tester.longPress(find.byType(FilterChip));
    await h.settle(tester);
    expect(find.text('Ada'), findsOneWidget);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the who-reacted sheet fits its list on desktop', (tester) async {
    expect(reactionsHeight(people: 2, window: 1000), lessThan(300));
    expect(reactionsHeight(people: 50, window: 1000), 500);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('the who-reacted sheet is half the window on a phone', (
    tester,
  ) async {
    expect(reactionsHeight(people: 2, window: 1000), 500);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

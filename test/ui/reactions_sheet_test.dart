import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
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
        _ => emptyAnswer(r),
      },
      home: (url) => Scaffold(
        body: PostEnvironment(
          server: Uri.parse(url),
          options: const ParseOptions(),
          myUsername: 'river',
          onMention: (_, _) {},
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
      handle: emptyAnswer,
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
      handle: emptyAnswer,
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

  Future<double> sheetHeight(WidgetTester tester, int people) async {
    final h = await pumpWithServer(
      tester,
      handle: emptyAnswer,
      home: (url) => Scaffold(
        body: ReactionsBar(
          reactions: [
            ReactionGroup(
              emojiName: 'tada',
              people: [
                for (var i = 0; i < people; i++)
                  (
                    id: 'u$i',
                    name: 'Person $i',
                    username: 'p$i',
                    pictureAt: null,
                  ),
              ],
              mine: false,
            ),
          ],
        ),
      ),
    );
    final chip = find.byType(FilterChip);
    if (isDesktop) {
      await tester.tap(chip, buttons: kSecondaryButton);
    } else {
      await tester.longPress(chip);
    }
    await h.settle(tester);
    final height = tester
        .getSize(
          find
              .ancestor(of: find.byType(TabBar), matching: find.byType(Column))
              .first,
        )
        .height;
    await h.close(tester);
    return height;
  }

  testWidgets('on desktop the who-reacted popup is as tall as its list, up to '
      'half the window', (tester) async {
    final half =
        tester.view.physicalSize.height / tester.view.devicePixelRatio / 2;
    expect(await sheetHeight(tester, 2), lessThan(half * 0.8));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets(
    'on desktop a long who-reacted list is capped at half the window',
    (tester) async {
      final half =
          tester.view.physicalSize.height / tester.view.devicePixelRatio / 2;
      expect(await sheetHeight(tester, 50), lessThanOrEqualTo(half));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('on a phone the who-reacted sheet is half the window', (
    tester,
  ) async {
    final half =
        tester.view.physicalSize.height / tester.view.devicePixelRatio / 2;
    expect(await sheetHeight(tester, 2), closeTo(half, half * 0.45));
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

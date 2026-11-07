import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/reactions_bar.dart';

import '../support/pump_app.dart';

ReactionGroup _group(String emoji, {required bool mine}) => ReactionGroup(
  emojiName: emoji,
  people: const [(id: 'u1', name: 'Wren', username: 'wren', pictureAt: null)],
  mine: mine,
);

BorderSide _side(WidgetTester tester, int index) =>
    tester.widget<FilterChip>(find.byType(FilterChip).at(index)).side!;

void main() {
  group('the tooltip names who reacted', () {
    PostPerson person(String name) => (
      id: 'u-$name',
      name: name,
      username: name.toLowerCase(),
      pictureAt: null,
    );
    String tooltip(List<PostPerson> people, {bool mine = false}) =>
        reactionTooltip(
          ReactionGroup(emojiName: 'tada', people: people, mine: mine),
          myUsername: 'me',
        );

    test('one, two and three people', () {
      expect(tooltip([person('Wren')]), 'Wren reacted with :tada:');
      expect(
        tooltip([person('Wren'), person('Kit')]),
        'Wren and Kit reacted with :tada:',
      );
      expect(
        tooltip([person('Wren'), person('Kit'), person('Ash')]),
        'Wren, Kit and Ash reacted with :tada:',
      );
    });

    test('you come first, as "You"', () {
      expect(
        tooltip([person('Wren'), person('Me')], mine: true),
        'You and Wren reacted with :tada:',
      );
      expect(tooltip([person('Me')], mine: true), 'You reacted with :tada:');
    });

    test('more than three are counted', () {
      final many = [
        for (final n in ['A', 'B', 'C', 'D', 'E']) person(n),
      ];
      expect(tooltip(many), 'A, B, C and 2 others reacted with :tada:');
      expect(
        tooltip(many.take(4).toList()),
        'A, B, C and 1 other reacted with :tada:',
      );
    });

    test('people not loaded yet are counted, not named', () {
      const unknown = (id: 'u-x', name: '', username: '', pictureAt: null);
      expect(
        tooltip([person('Wren'), unknown]),
        'Wren and 1 other reacted with :tada:',
      );
      expect(tooltip([unknown, unknown]), '2 people reacted with :tada:');
    });
  });

  testWidgets('reactions keep a little gap below what is above them', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50, width: 200),
            ReactionsBar(reactions: [_group('tada', mine: false)]),
          ],
        ),
      ),
    );
    final gap = tester.getTopLeft(find.byType(FilterChip)).dy - 50;
    expect(gap, greaterThanOrEqualTo(4));
    expect(gap, lessThan(12));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('an own reaction is outlined in the primary colour, others not', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: ReactionsBar(
          reactions: [_group('tada', mine: true), _group('eyes', mine: false)],
        ),
      ),
    );
    final primary = Theme.of(tester.element(find.byType(ReactionsBar)))
        .colorScheme
        .primary;
    expect(_side(tester, 0).color, primary);
    expect(_side(tester, 1).color, isNot(primary));
  });

  testWidgets('toggling the own reaction leaves the chip the same size', (
    tester,
  ) async {
    Future<Size> size({required bool mine}) async {
      await pumpApp(
        tester,
        Scaffold(
          body: ReactionsBar(reactions: [_group('tada', mine: mine)]),
        ),
      );
      return tester.getSize(find.byType(FilterChip));
    }

    expect(await size(mine: true), await size(mine: false));
  });
}

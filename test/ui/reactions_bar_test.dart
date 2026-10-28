import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/reactions_bar.dart';

ReactionGroup _group(String emoji, {required bool mine}) => ReactionGroup(
  emojiName: emoji,
  people: const [(id: 'u1', name: 'Wren', username: 'wren', pictureAt: null)],
  mine: mine,
);

BorderSide _side(WidgetTester tester, int index) =>
    tester.widget<FilterChip>(find.byType(FilterChip).at(index)).side!;

void main() {
  testWidgets('an own reaction is outlined in the primary colour, others not', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: ReactionsBar(
            reactions: [
              _group('tada', mine: true),
              _group('eyes', mine: false),
            ],
          ),
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
      await tester.pumpWidget(
        MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Scaffold(
            body: ReactionsBar(reactions: [_group('tada', mine: mine)]),
          ),
        ),
      );
      return tester.getSize(find.byType(FilterChip));
    }

    expect(await size(mine: true), await size(mine: false));
  });
}

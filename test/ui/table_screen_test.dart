import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/table_block.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('a short table leaves no unpainted area under the header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const TableScreen(
        table: TableBlock(
          [CellAlign.start],
          [
            [
              [Inline.text('Head')],
            ],
            [
              [Inline.text('Cell')],
            ],
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final page = Theme.of(tester.element(find.text('Cell')))
        .scaffoldBackgroundColor;
    final bottom = tester.getBottomLeft(find.byType(Scaffold)).dy;
    final painted = find
        .ancestor(of: find.text('Cell'), matching: find.byType(Material))
        .evaluate()
        .where((e) => (e.widget as Material).color == page)
        .map(
          (e) =>
              tester.getBottomLeft(find.byElementPredicate((x) => x == e)).dy,
        );
    expect(painted, contains(bottom));
  });
}

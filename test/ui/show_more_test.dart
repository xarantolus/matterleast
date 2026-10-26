import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/markdown/show_more.dart';

void main() {
  final controller = AnchoredListController();
  final expanded = <String>{};

  // Newest first: short rows around one long message, id 5.
  Widget list(List<int> rows) => MaterialApp(
    theme: MatterleastApp.lightTheme,
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: ShowMoreMemory(
          expanded: expanded,
          child: AnchoredList<int>(
            rows: rows,
            keyOf: (id) => id,
            controller: controller,
            itemBuilder: (_, id) => id == 5
                ? ShowMore(
                    id: 'long',
                    child: Column(
                      children: [
                        for (var line = 1; line <= 40; line++)
                          SizedBox(height: 30, child: Text('line $line')),
                      ],
                    ),
                  )
                : SizedBox(height: 80, child: Text('row $id')),
          ),
        ),
      ),
    ),
  );

  final rows = [for (var id = 10; id >= 1; id--) id];

  testWidgets('expanding a message cut above the screen keeps the text where '
      'the reader is and grows downwards', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    expanded.clear();
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    // The long message's top is above the screen, its cut on screen.
    controller.jumpTo(5, offset: 400);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('line 1')).dy, lessThan(0));
    final reading = tester.getTopLeft(find.text('line 8')).dy;

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('line 8')).dy, closeTo(reading, 0.5));
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('a message stays expanded when its row is built again', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    expanded.clear();
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    controller.jumpTo(5, offset: 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(list(rows));
    await tester.pumpAndSettle();
    controller.jumpTo(5, offset: 0);
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
  });
}

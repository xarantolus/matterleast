import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/markdown/table_block.dart';

String _table(int rows, int columns, String Function(int, int) cell) {
  final head = '| ${List.generate(columns, (c) => 'H$c').join(' | ')} |';
  final rule = '| ${List.filled(columns, '---').join(' | ')} |';
  final body = [
    for (var r = 0; r < rows; r++)
      '| ${List.generate(columns, (c) => cell(r, c)).join(' | ')} |',
  ];
  return [head, rule, ...body].join('\n');
}

Future<void> _show(WidgetTester tester, String message, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse('https://chat.example.test'),
            options: const ParseOptions(),
            myUsername: 'me',
            onMention: (_) {},
            onChannel: (_) {},
            onLink: (_) {},
            child: ListView(
              children: [PostBody(postId: 'p1', message: message)],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a wide window shows every cell in the message and a tap '
      'opens nothing', (tester) async {
    await _show(
      tester,
      _table(8, 3, (r, c) => 'r${r}c$c'),
      const Size(1400, 900),
    );
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 3; c++) {
        expect(find.text('r${r}c$c'), findsOneWidget);
      }
    }
    await tester.tap(find.text('r2c1'));
    await tester.pumpAndSettle();
    expect(find.byType(TableScreen), findsNothing);
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('a table wider than the message scrolls sideways inside it', (
    tester,
  ) async {
    await _show(
      tester,
      _table(2, 12, (r, c) => 'a fairly long cell $r $c'),
      const Size(1400, 900),
    );
    final sideways = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: sideways, matching: find.byType(Scrollable)),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    expect(scrollable.position.pixels, 0);

    // A wheel turn with Shift held moves it sideways.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.text('H0')),
        scrollDelta: const Offset(0, 200),
      ),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(scrollable.position.pixels, greaterThan(0));
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/message_display.dart';

// About 5 MB of source: 100,000 lines of 50 characters.
final _huge = [
  for (var i = 1; i <= 100000; i++)
    'final value$i = compute(argument$i, other: $i);',
].join('\n');

Future<void> _open(WidgetTester tester, String code) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: MessageDisplay(
          textScale: 1,
          wrapCode: false,
          child: CodeScreen(code: code, language: 'dart'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a huge file shows its first lines', (tester) async {
    await _open(tester, _huge);
    expect(
      find.textContaining('value1 = compute', findRichText: true),
      findsWidgets,
    );
  });
}

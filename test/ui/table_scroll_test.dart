import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';

import '../support/pump_app.dart';

final _wideTable = [
  '| ${List.generate(14, (c) => 'H$c').join(' | ')} |',
  '| ${List.filled(14, '---').join(' | ')} |',
  for (var r = 0; r < 12; r++)
    '| ${List.generate(14, (c) => 'value $r $c padding').join(' | ')} |',
].join('\n');

final _wideCode = [
  '```',
  for (var r = 0; r < 12; r++) 'line $r ${'x' * 400}',
  '```',
].join('\n');

void main() {
  testWidgets('wheel turns over tables and code blocks scroll the list by '
      'the delta, also the first ones after leaving the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      Scaffold(
        body: PostEnvironment(
          server: Uri.parse('https://chat.example.test'),
          options: const ParseOptions(),
          myUsername: 'me',
          onMention: (_, _) {},
          onChannel: (_) {},
          onLink: (_) {},
          child: AnchoredList<int>(
            rows: [for (var i = 20; i >= 0; i--) i],
            keyOf: (i) => i,
            controller: AnchoredListController(),
            itemBuilder: (_, i) => PostBody(
              postId: 'p$i',
              message: i.isEven
                  ? 'row $i\n\n$_wideTable'
                  : 'row $i\n\n$_wideCode',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Map<String, double> tops() => {
      for (final e in find.byType(RichText).evaluate())
        if ((e.widget as RichText).text.toPlainText() case final text
            when text.startsWith('row '))
          text: tester.getTopLeft(find.byWidget(e.widget)).dy,
    };
    expect(tops(), isNotEmpty);
    for (var step = 0; step < 12; step++) {
      final before = tops();
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: const Offset(60, 450),
          scrollDelta: const Offset(0, -40),
        ),
      );
      await tester.pump();
      final after = tops();
      for (final key in before.keys.where(after.containsKey)) {
        expect(
          after[key]! - before[key]!,
          closeTo(40, 0.5),
          reason: 'step $step $key',
        );
      }
    }
  });
}

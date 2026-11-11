import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';

import '../support/pump_app.dart';

Future<void> _show(WidgetTester tester, String message) => pumpApp(
  tester,
  Scaffold(
    body: PostEnvironment(
      server: Uri.parse('https://chat.example.test'),
      options: const ParseOptions(),
      myUsername: 'river',
      onMention: (_, _) {},
      onChannel: (_) {},
      onLink: (_) {},
      child: PostBody(postId: 'p1', message: message),
    ),
  ),
);

TextStyle? _styleOf(WidgetTester tester, String text) {
  TextStyle? found;
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text == text) {
        found = rich.text.style?.merge(span.style) ?? span.style;
      }
      return true;
    });
  }
  return found;
}

void main() {
  testWidgets('a message of typed emoji is drawn large in the emoji font', (
    tester,
  ) async {
    await _show(tester, '😀😀😀');
    final style = _styleOf(tester, '😀');
    expect(style?.fontFamily, emojiFont);
    expect(style?.fontSize, greaterThan(24));
  });

  testWidgets('a typed emoji among words uses the emoji font at text size', (
    tester,
  ) async {
    await _show(tester, 'hi ❤️');
    final style = _styleOf(tester, '❤️');
    expect(style?.fontFamily, emojiFont);
    expect(style?.fontSize, lessThan(24));
  });
}

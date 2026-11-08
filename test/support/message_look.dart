import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// Whether the message showing [text] is drawn on the wash that marks the
/// message a link or notification led to.
bool isHighlighted(WidgetTester tester, String text) {
  final shown = find.text(text);
  final wash = Theme.of(tester.element(shown))
      .extension<AppTokens>()!
      .accentWash;
  final behind = find.ancestor(of: shown, matching: find.byType(DecoratedBox));
  return tester
      .widgetList<DecoratedBox>(behind)
      .any(
        (box) => switch (box.decoration) {
          BoxDecoration(:final color) => color == wash,
          _ => false,
        },
      );
}

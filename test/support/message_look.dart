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

/// Runs [settle] and says whether the message showing [text] was drawn on
/// the highlight at any round of it. The wash fades after a moment, so
/// looking only once settling is over would depend on how long it took.
Future<bool> highlightedWhileSettling(
  WidgetTester tester,
  String text,
  Future<void> Function({bool Function()? until}) settle,
) async {
  var seen = false;
  await settle(
    until: () {
      if (find.text(text).evaluate().isNotEmpty &&
          isHighlighted(tester, text)) {
        seen = true;
      }
      return true;
    },
  );
  return seen;
}

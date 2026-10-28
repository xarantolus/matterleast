import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/tokens.dart';

void main() {
  test('inline code lets a selection show through and looks as before on '
      'the page', () {
    for (final tokens in [AppTokens.light, AppTokens.dark]) {
      final shade = seeThroughCode(tokens);
      expect(shade.a, lessThan(0.5));
      final onPage = Color.alphaBlend(shade, tokens.page);
      for (final (shown, wanted) in [
        (onPage.r, tokens.codeBackground.r),
        (onPage.g, tokens.codeBackground.g),
        (onPage.b, tokens.codeBackground.b),
      ]) {
        expect(shown, closeTo(wanted, 3 / 255));
      }
    }
  });
}

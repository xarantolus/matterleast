import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/composer_desktop.dart';

void main() {
  const field = Rect.fromLTWH(100, 700, 900, 60);

  test('on a phone the suggestions are as wide as the field', () {
    final span = suggestionSpan(field, 1000, desktop: false);
    expect((span.left, span.width), (100, 900));
  });

  test('on desktop they are a card a third of the window wide', () {
    final span = suggestionSpan(field, 1200, desktop: true);
    expect((span.left, span.width), (100, 400));
  });

  test('a small window keeps the card readable but inside the field', () {
    expect(suggestionSpan(field, 600, desktop: true).width, 280);
    const narrow = Rect.fromLTWH(10, 700, 200, 60);
    expect(suggestionSpan(narrow, 1200, desktop: true).width, 200);
  });
}

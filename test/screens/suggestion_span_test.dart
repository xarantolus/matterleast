import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/channel/composer_desktop.dart';

void main() {
  test('on a phone the suggestions are as wide as the field', () {
    expect(suggestionWidth(900, 1000, desktop: false), 900);
  });

  test('on desktop they are a card a third of the window wide', () {
    expect(suggestionWidth(900, 1200, desktop: true), 400);
  });

  test('a small window keeps the card readable but inside the field', () {
    expect(suggestionWidth(900, 600, desktop: true), 280);
    expect(suggestionWidth(200, 1200, desktop: true), 200);
  });
}

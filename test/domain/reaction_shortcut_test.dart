import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/reaction_shortcut.dart';

void main() {
  test('+:name: adds and -:name: takes back', () {
    expect(reactionShortcut('+:tada:'), (add: true, emojiName: 'tada'));
    expect(reactionShortcut('-:+1: '), (add: false, emojiName: '+1'));
  });

  test('anything else is ordinary text', () {
    expect(reactionShortcut('+:tada: thanks'), isNull);
    expect(reactionShortcut('great +:tada:'), isNull);
    expect(reactionShortcut('+:two words:'), isNull);
    expect(reactionShortcut(':tada:'), isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/notifications/conversation_tile.dart';

void main() {
  test('a tile shows the first letter or digit, capital', () {
    expect(tileLetter('town square'), 'T');
    expect(tileLetter('  #ops'), 'O');
    expect(tileLetter('42 crew'), '4');
    expect(tileLetter('!!!'), '#');
  });

  test('a conversation keeps the same tile colour', () {
    expect(tileColor('Regatta'), tileColor('Regatta'));
  });
}

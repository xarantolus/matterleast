import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/typing.dart';

void main() {
  test('says who is typing in plain words', () {
    expect(typingText([]), isNull);
    expect(typingText(['bob']), 'bob is typing…');
    expect(typingText(['bob', 'carol']), 'bob and carol are typing…');
    expect(
      typingText(['bob', 'carol', 'dave', 'erin']),
      'bob, carol and 2 more are typing…',
    );
  });
}

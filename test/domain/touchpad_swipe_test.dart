import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/touchpad_swipe.dart';

void main() {
  test('left is back and right is forward', () {
    expect(swipeState(-20).forward, isFalse);
    expect(swipeState(20).forward, isTrue);
    expect(swipeState(0).forward, isNull);
  });

  test('the ratio grows with the distance and stops at one', () {
    expect(swipeState(swipeDistance / 4).ratio, closeTo(0.25, 1e-9));
    expect(swipeState(-swipeDistance * 3).ratio, 1);
  });

  test('only a full swipe goes through', () {
    expect(swipeStep(-swipeDistance + 1), isNull);
    expect(swipeStep(-swipeDistance), isFalse);
    expect(swipeStep(swipeDistance), isTrue);
  });
}

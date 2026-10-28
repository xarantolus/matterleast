import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/gallery/slide_to_close.dart';

void main() {
  const height = 800.0;
  bool closes(double offset, double velocity) =>
      slideCloses(offset: offset, velocity: velocity, height: height);

  test('a slide of a tenth of the screen closes, either way', () {
    expect(closes(80, 0), isTrue);
    expect(closes(-80, 0), isTrue);
    expect(closes(79, 0), isFalse);
  });

  test('a quick fling closes however short it was', () {
    expect(closes(12, 900), isTrue);
    expect(closes(-12, -900), isTrue);
  });

  test('a slow or reversed let-go springs back', () {
    expect(closes(40, 300), isFalse);
    expect(closes(40, -900), isFalse);
    expect(closes(0, 2000), isFalse);
  });
}

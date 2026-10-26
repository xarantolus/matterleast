import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/wait_limited.dart';

void main() {
  test('runs at most three at once and keeps the order', () async {
    var running = 0;
    var most = 0;
    final results = await waitLimited(List.generate(10, (i) => i), (i) async {
      running++;
      if (running > most) most = running;
      await Future<void>.delayed(Duration(milliseconds: 10 - i));
      running--;
      return i * 2;
    });
    expect(most, 3);
    expect(results, List.generate(10, (i) => i * 2));
  });

  test('a failure is thrown after every item has run', () async {
    final ran = <int>[];
    await expectLater(
      waitLimited([1, 2, 3, 4, 5], (i) async {
        ran.add(i);
        if (i == 2) throw StateError('two');
        return i;
      }),
      throwsA(isA<StateError>()),
    );
    expect(ran, [1, 2, 3, 4, 5]);
  });
}

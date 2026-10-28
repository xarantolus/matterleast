import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/open_history.dart';

bool _all(String _) => true;

void main() {
  test('back and forward walk the opened conversations', () {
    final h = OpenHistory<String>()
      ..push('a')
      ..push('b')
      ..push('c');
    expect(h.step(forward: false, exists: _all), 'b');
    expect(h.step(forward: false, exists: _all), 'a');
    expect(h.step(forward: false, exists: _all), isNull);
    expect(h.current, 'a');
    expect(h.step(forward: true, exists: _all), 'b');
    expect(h.step(forward: true, exists: _all), 'c');
    expect(h.step(forward: true, exists: _all), isNull);
  });

  test('opening something new drops what was ahead', () {
    final h = OpenHistory<String>()
      ..push('a')
      ..push('b')
      ..push('c');
    h.step(forward: false, exists: _all);
    h.push('d');
    expect(h.entries, ['a', 'b', 'd']);
    expect(h.step(forward: true, exists: _all), isNull);
  });

  test('opening the one already shown adds nothing', () {
    final h = OpenHistory<String>()
      ..push('a')
      ..push('a');
    expect(h.entries, ['a']);
  });

  test('keeps only the last entries', () {
    final h = OpenHistory<int>(limit: 3);
    for (var i = 0; i < 5; i++) {
      h.push(i);
    }
    expect(h.entries, [2, 3, 4]);
    expect(h.current, 4);
  });

  test('back skips and forgets what is gone', () {
    final h = OpenHistory<String>()
      ..push('a')
      ..push('gone')
      ..push('c');
    expect(h.step(forward: false, exists: (e) => e != 'gone'), 'a');
    expect(h.entries, ['a', 'c']);
    expect(h.step(forward: true, exists: _all), 'c');
  });

  test('forward skips what is gone and stays put when nothing is left', () {
    final h = OpenHistory<String>()
      ..push('a')
      ..push('b')
      ..push('gone');
    h.step(forward: false, exists: _all);
    h.step(forward: false, exists: _all);
    expect(
      h.step(forward: true, exists: (e) => e != 'gone' && e != 'b'),
      isNull,
    );
    expect(h.current, 'a');
    expect(h.entries, ['a']);
  });
}

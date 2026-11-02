import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/rail_order.dart';
import 'package:matterleast/domain/teams.dart';

void main() {
  group('moving an item', () {
    const items = ['a', 'b', 'c', 'd'];
    for (final (from, to, expected) in [
      (0, 2, ['b', 'c', 'a', 'd']),
      (3, 0, ['d', 'a', 'b', 'c']),
      (1, 1, ['a', 'b', 'c', 'd']),
      (2, 3, ['a', 'b', 'd', 'c']),
      (-1, 2, ['a', 'b', 'c', 'd']),
      (0, 4, ['a', 'b', 'c', 'd']),
    ]) {
      test('$from to $to gives $expected', () {
        expect(moveItem(items, from, to), expected);
      });
    }
  });

  test('arranging puts the named ones first and keeps the rest in order', () {
    expect(arrangedBy(['a', 'b', 'c', 'd'], ['c', 'a'], (s) => s), [
      'c',
      'a',
      'b',
      'd',
    ]);
    expect(arrangedBy(['a', 'b'], null, (s) => s), ['a', 'b']);
    expect(arrangedBy(['a', 'b'], ['x', 'b'], (s) => s), ['b', 'a']);
  });

  test('a saved team order is what the server sorts by, new teams last', () {
    final saved = teamsOrderValue(moveItem(['h', 'l', 'a'], 2, 0));
    expect(saved, 'a,h,l');
    const teams = [
      (id: 'h', displayName: 'harbor'),
      (id: 'l', displayName: 'Lighthouse'),
      (id: 'a', displayName: 'Atlas'),
      (id: 'z', displayName: 'Zephyr'),
      (id: 'b', displayName: 'Bay'),
    ];
    expect(sortTeams(teams, saved).map((t) => t.id), ['a', 'h', 'l', 'b', 'z']);
  });
}

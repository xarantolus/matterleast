import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/paged_search.dart';

Object _key(String s) => s;

void main() {
  test('pages add up without duplicates, until the server says no more', () {
    var s = const PagedSearch<String>();
    expect(s.wantsMore, isTrue);
    s = s.pageRequested();
    expect(s.wantsMore, isFalse, reason: 'one page at a time');
    s = s.pageArrived((items: ['a', 'b'], more: true), _key);
    expect(s.items, ['a', 'b']);
    expect(s.nextPage, 1);
    s = s.pageRequested().pageArrived((items: ['b', 'c'], more: false), _key);
    expect(s.items, ['a', 'b', 'c']);
    expect(s.wantsMore, isFalse);
  });

  test('a short page still asks for more when the server has more', () {
    final s = const PagedSearch<String>().pageRequested().pageArrived((
      items: ['a'],
      more: true,
    ), _key);
    expect(s.wantsMore, isTrue);
  });

  test('a failed page can be asked for again', () {
    final s = const PagedSearch<String>().pageRequested().pageFailed('down');
    expect(s.error, 'down');
    expect(s.wantsMore, isTrue);
    expect(s.pageRequested().error, isNull);
  });

  test('an answer for an older term is dropped', () {
    var s = const PagedSearch<String>().typed(' an ').searchRequested();
    expect(s.term, 'an');
    s = s.typed('ann');
    s = s.searchArrived('an', ['ana', 'anton']);
    expect(s.found, isNull);
    s = s.searchArrived('ann', ['anna']);
    expect(s.found, ['anna']);
    expect(s.wantsMore, isFalse, reason: 'matches replace the pages');
    expect(s.typed('').found, isNull);
  });

  test('starting over keeps the term but nothing loaded', () {
    final s = const PagedSearch<String>()
        .pageArrived((items: ['a'], more: false), _key)
        .typed('a')
        .searchArrived('a', ['a'])
        .restarted();
    expect(s.items, isEmpty);
    expect(s.found, isNull);
    expect(s.term, 'a');
    expect(s.wantsMore, isTrue);
  });
}

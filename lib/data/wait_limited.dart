import 'dart:math';

/// Runs [work] for each of [items] with at most [limit] running at once and
/// returns the results in order. Like [Future.wait], every item runs even
/// when one fails, and the first failure is thrown once all have finished.
Future<List<R>> waitLimited<T, R>(
  Iterable<T> items,
  Future<R> Function(T item) work, {
  int limit = 3,
}) async {
  final list = items.toList();
  final results = List<R?>.filled(list.length, null);
  (Object, StackTrace)? failure;
  var next = 0;
  Future<void> worker() async {
    while (next < list.length) {
      final i = next++;
      try {
        results[i] = await work(list[i]);
      } on Object catch (e, s) {
        failure ??= (e, s);
      }
    }
  }

  await Future.wait([
    for (var i = 0; i < min(limit, list.length); i++) worker(),
  ]);
  if (failure case (final e, final s)) Error.throwWithStackTrace(e, s);
  return results.cast<R>();
}

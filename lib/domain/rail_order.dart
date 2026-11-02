/// Pure: [items] after the one at [oldIndex] was dragged to [newIndex], its
/// place once it was taken out (as `onReorderItem` numbers it).
List<T> moveItem<T>(List<T> items, int oldIndex, int newIndex) {
  if (oldIndex < 0 ||
      oldIndex >= items.length ||
      newIndex < 0 ||
      newIndex >= items.length) {
    return items;
  }
  final next = [...items];
  next.insert(newIndex, next.removeAt(oldIndex));
  return next;
}

/// Pure: [items] in the order of [ids]; items not named keep their order
/// after the named ones.
List<T> arrangedBy<T>(
  List<T> items,
  List<String>? ids,
  String Function(T) idOf,
) {
  if (ids == null) return items;
  int rank(T item) {
    final i = ids.indexOf(idOf(item));
    return i < 0 ? ids.length : i;
  }

  final ranked = [for (final (i, item) in items.indexed) (item, i)]
    ..sort((a, b) {
      final byRank = rank(a.$1).compareTo(rank(b.$1));
      return byRank != 0 ? byRank : a.$2.compareTo(b.$2);
    });
  return [for (final r in ranked) r.$1];
}

/// The `teams_order` preference value for teams in [ids] order.
String teamsOrderValue(Iterable<String> ids) => ids.join(',');

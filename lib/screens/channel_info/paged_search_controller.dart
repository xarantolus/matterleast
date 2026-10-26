import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/paged_search.dart';

/// Runs a [PagedSearch]: asks for pages and searches, waits for a pause in
/// typing, and drops answers that came too late. Screens render [value].
class PagedSearchController<T> extends ValueNotifier<PagedSearch<T>> {
  PagedSearchController({
    required this.loadPage,
    required this.search,
    required this.keyOf,
    this.searchDelay = const Duration(milliseconds: 400),
    this.keepLoadingBelow = 0,
  }) : super(PagedSearch<T>());

  Future<ServerPage<T>> Function(int page) loadPage;

  /// The server's matches for a term; null searches only what is loaded.
  Future<List<T>> Function(String term)? search;
  final Object Function(T) keyOf;
  final Duration searchDelay;

  /// A page with fewer items than this asks for the next one at once, for
  /// sources that leave much of a page out.
  final int keepLoadingBelow;

  Timer? _debounce;
  var _generation = 0;
  var _disposed = false;

  /// Asks for the next page unless one is on its way or none is left.
  Future<void> more() async {
    if (!value.wantsMore) return;
    final generation = _generation;
    final page = value.nextPage;
    value = value.pageRequested();
    try {
      final next = await loadPage(page);
      if (_stale(generation)) return;
      value = value.pageArrived(next, keyOf);
      if (next.more && next.items.length < keepLoadingBelow) {
        unawaited(more());
      }
    } on Object catch (e) {
      if (_stale(generation)) return;
      value = value.pageFailed(e);
    }
  }

  /// After a failure: the search again, or the page that failed.
  Future<void> retry() async =>
      value.term.isEmpty || search == null ? more() : typed(value.term);

  void typed(String text) {
    _debounce?.cancel();
    value = value.typed(text);
    final term = value.term;
    final search = this.search;
    if (term.isEmpty || search == null) return;
    _debounce = Timer(searchDelay, () async {
      if (_disposed) return;
      value = value.searchRequested();
      try {
        final found = await search(term);
        if (_disposed) return;
        value = value.searchArrived(term, found);
      } on Object catch (e) {
        if (_disposed) return;
        value = value.searchFailed(term, e);
      }
    });
  }

  /// Starts over from the first page with new sources, such as another
  /// filter, keeping what was typed.
  Future<void> restart() {
    _generation++;
    value = value.restarted();
    typed(value.term);
    return more();
  }

  bool _stale(int generation) => _disposed || generation != _generation;

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}

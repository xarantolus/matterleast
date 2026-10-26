import 'package:flutter/foundation.dart';

/// One page from the server; [more] says whether another may follow.
typedef ServerPage<T> = ({List<T> items, bool more});

/// A list loaded a page at a time from the server, which a search term can
/// replace with the server's matches.
@immutable
class PagedSearch<T> {
  const PagedSearch({
    this.items = const [],
    this.nextPage = 0,
    this.more = true,
    this.loading = false,
    this.error,
    this.term = '',
    this.found,
    this.searching = false,
  });

  /// Everything paged in so far, without duplicates.
  final List<T> items;
  final int nextPage;
  final bool more;
  final bool loading;

  /// Why the last page or search failed.
  final Object? error;
  final String term;

  /// The server's matches for [term]; null while there is no term or no
  /// answer yet.
  final List<T>? found;
  final bool searching;

  /// Something is on its way from the server.
  bool get busy => loading || searching;

  /// A further page is worth asking for: the pages are shown, not the
  /// server's matches.
  bool get wantsMore => more && !loading && found == null;

  PagedSearch<T> _copy({
    List<T>? items,
    int? nextPage,
    bool? more,
    bool? loading,
    Object? error,
    bool clearError = false,
    String? term,
    List<T>? found,
    bool clearFound = false,
    bool? searching,
  }) => PagedSearch(
    items: items ?? this.items,
    nextPage: nextPage ?? this.nextPage,
    more: more ?? this.more,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
    term: term ?? this.term,
    found: clearFound ? null : found ?? this.found,
    searching: searching ?? this.searching,
  );

  PagedSearch<T> pageRequested() => _copy(loading: true, clearError: true);

  PagedSearch<T> pageArrived(ServerPage<T> page, Object Function(T) keyOf) {
    final known = {for (final i in items) keyOf(i)};
    return _copy(
      items: [
        ...items,
        for (final i in page.items)
          if (known.add(keyOf(i))) i,
      ],
      nextPage: nextPage + 1,
      more: page.more,
      loading: false,
    );
  }

  PagedSearch<T> pageFailed(Object error) =>
      _copy(loading: false, error: error);

  /// A new term: the old matches go, and an empty term shows the pages.
  PagedSearch<T> typed(String text) => _copy(
    term: text.trim(),
    clearFound: true,
    searching: false,
    clearError: true,
  );

  PagedSearch<T> searchRequested() => _copy(searching: true);

  /// Matches for [forTerm]; an answer to an older term is dropped.
  PagedSearch<T> searchArrived(String forTerm, List<T> found) =>
      forTerm != term ? this : _copy(found: found, searching: false);

  PagedSearch<T> searchFailed(String forTerm, Object error) => forTerm != term
      ? this
      : _copy(found: const [], searching: false, error: error);

  /// Starts again from the first page, keeping the term.
  PagedSearch<T> restarted() => PagedSearch(term: term);
}

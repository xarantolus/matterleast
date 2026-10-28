/// The conversations and threads the user opened, oldest first, with the
/// one shown now, so Back and Forward move through them like a browser.
/// Opening something new drops what was ahead.
class OpenHistory<T> {
  OpenHistory({this.limit = 50});

  final int limit;
  final _entries = <T>[];
  var _at = -1;

  List<T> get entries => List.unmodifiable(_entries);

  T? get current => _at >= 0 ? _entries[_at] : null;

  /// [entry] was opened; the same as the current one changes nothing.
  void push(T entry) {
    if (current == entry) return;
    _entries.removeRange(_at + 1, _entries.length);
    _entries.add(entry);
    if (_entries.length > limit) _entries.removeAt(0);
    _at = _entries.length - 1;
  }

  /// Moves to the nearest entry before (or after) the current one that
  /// [exists] and returns it; entries that don't are dropped. Null, and
  /// nothing moved, when there is none.
  T? step({required bool forward, required bool Function(T) exists}) {
    var i = _at + (forward ? 1 : -1);
    while (i >= 0 && i < _entries.length) {
      if (exists(_entries[i])) {
        _at = i;
        return _entries[i];
      }
      _entries.removeAt(i);
      if (!forward) {
        _at--;
        i--;
      }
    }
    return null;
  }
}

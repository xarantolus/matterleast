import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Where the reader is in an [AnchoredList], reported after each scroll and
/// each change of rows. Indexes count from the newest row (0).
@immutable
class AnchoredListView {
  const AnchoredListView({
    required this.pinned,
    required this.nearOlderEnd,
    required this.newestVisible,
    required this.oldestVisible,
  });

  /// At the bottom, so new rows enter there and lift the list.
  final bool pinned;

  /// Within one and a half screens of the oldest row: time to load more.
  final bool nearOlderEnd;
  final int? newestVisible;
  final int? oldestVisible;

  @override
  bool operator ==(Object other) =>
      other is AnchoredListView &&
      other.pinned == pinned &&
      other.nearOlderEnd == nearOlderEnd &&
      other.newestVisible == newestVisible &&
      other.oldestVisible == oldestVisible;

  @override
  int get hashCode =>
      Object.hash(pinned, nearOlderEnd, newestVisible, oldestVisible);
}

/// A row and the distance of its bottom edge above the list's bottom edge.
typedef AnchoredPosition = ({Object key, double offset});

/// Moves an [AnchoredList] from outside.
class AnchoredListController {
  _AnchoredListState<Object?>? _state;

  /// The bottom-most visible row and where it sits, to restore later.
  AnchoredPosition? get position => _state?._measuredAnchor();

  bool get pinned => _state?._lastView?.pinned ?? true;

  void jumpToBottom() => _state?._jumpToBottom();

  Future<void> animateToBottom() async => _state?._animateToBottom();

  /// Puts the bottom edge of row [key] [offset] above the list's bottom.
  void jumpTo(Object key, {required double offset}) =>
      _state?._jumpTo(key, offset);

  /// Puts row [key] so its bottom edge is [fraction] of the list's height
  /// above the bottom.
  void jumpToFraction(Object key, double fraction) =>
      _state?._jumpToFraction(key, fraction);

  /// Centres row [key] once it is laid out.
  void centre(Object key) => _state?._centre(key);
}

/// A chat list, newest row at the bottom, whose visible rows never move when
/// rows are added on either side or change height elsewhere.
///
/// The rows are split at an anchor row: the anchor and everything older grow
/// up from the scroll origin, everything newer grows down from it, so no
/// insertion shifts the origin. When scrolling settles, the bottom-most
/// visible row becomes the anchor, and the offset is rewritten in the same
/// frame so nothing moves on screen.
class AnchoredList<T> extends StatefulWidget {
  const AnchoredList({
    required this.rows,
    required this.keyOf,
    required this.itemBuilder,
    required this.controller,
    this.initialAnchor,
    this.olderEdge,
    this.onViewChanged,
    this.onDragStart,
    super.key,
  });

  /// Newest first.
  final List<T> rows;
  final Object Function(T row) keyOf;
  final Widget Function(BuildContext context, T row) itemBuilder;
  final AnchoredListController controller;

  /// Where to open; the newest row at the bottom when null.
  final AnchoredPosition? initialAnchor;

  /// Shown above the oldest row: a spinner, a retry button, or the start of
  /// the conversation.
  final Widget? olderEdge;
  final ValueChanged<AnchoredListView>? onViewChanged;
  final VoidCallback? onDragStart;

  @override
  State<AnchoredList<T>> createState() => _AnchoredListState<T>();
}

class _AnchoredListState<T> extends State<AnchoredList<T>> {
  static const pinTolerance = 48.0;

  late final ScrollController _scroll;
  final _centerKey = UniqueKey();
  final _viewportKey = GlobalKey();
  final _built = <Object, BuildContext>{};
  var _indexOf = <Object, int>{};
  Object? _anchor;
  Object? _pendingCentre;
  AnchoredListView? _lastView;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this as _AnchoredListState<Object?>;
    _indexRows();
    final initial = widget.initialAnchor;
    final known = initial != null && _indexOf.containsKey(initial.key);
    _anchor = known ? initial.key : _newestKey;
    _scroll = ScrollController(
      keepScrollOffset: false,
      initialScrollOffset: known ? -initial.offset : 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _settle());
  }

  @override
  void didUpdateWidget(AnchoredList<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller._state = null;
      widget.controller._state = this as _AnchoredListState<Object?>;
    }
    if (identical(old.rows, widget.rows)) return;
    final oldIndex = _indexOf;
    final oldNewest = old.rows.isEmpty ? null : old.keyOf(old.rows.first);
    final wasPinned = _anchor == oldNewest && _isPinned();
    _indexRows();
    if (wasPinned || _anchor == null) {
      // New rows enter at the bottom: the newest row becomes the anchor and
      // the offset stays, so the list lifts.
      _anchor = _newestKey;
    } else if (!_indexOf.containsKey(_anchor)) {
      _anchor = _survivor(old.rows, old.keyOf, oldIndex);
    }
    _scheduleReport();
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _scroll.dispose();
    super.dispose();
  }

  Object? get _newestKey =>
      widget.rows.isEmpty ? null : widget.keyOf(widget.rows.first);

  void _indexRows() {
    _indexOf = {
      for (final (i, row) in widget.rows.indexed) widget.keyOf(row): i,
    };
  }

  /// The nearest older row that still exists, else the newest.
  Object? _survivor(
    List<T> oldRows,
    Object Function(T) oldKeyOf,
    Map<Object, int> oldIndex,
  ) {
    final from = oldIndex[_anchor];
    if (from != null) {
      for (var i = from + 1; i < oldRows.length; i++) {
        final key = oldKeyOf(oldRows[i]);
        if (_indexOf.containsKey(key)) return key;
      }
    }
    return _newestKey;
  }

  bool _isPinned() {
    if (!_scroll.hasClients) return true;
    final p = _scroll.position;
    return p.pixels - p.minScrollExtent <= pinTolerance;
  }

  int get _anchorIndex => _indexOf[_anchor] ?? 0;

  RenderBox? get _viewportBox =>
      _viewportKey.currentContext?.findRenderObject() as RenderBox?;

  /// Laid-out rows and their top and bottom in list coordinates (y down
  /// from the list's top edge).
  Iterable<({Object key, double top, double bottom})> _laidOut() sync* {
    final viewport = _viewportBox;
    if (viewport == null || !viewport.hasSize) return;
    for (final MapEntry(:key, value: context) in _built.entries) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      yield (key: key, top: top, bottom: top + box.size.height);
    }
  }

  AnchoredPosition? _measuredAnchor() {
    final viewport = _viewportBox;
    if (viewport == null || !viewport.hasSize) return null;
    final height = viewport.size.height;
    ({Object key, double top, double bottom})? best;
    for (final row in _laidOut()) {
      if (row.bottom <= 0 || row.top >= height) continue;
      // The lowest row whose bottom edge is on screen; a row taller than
      // the screen anchors by its bottom even when that is below.
      final onScreen = row.bottom <= height + 0.5;
      final bestOnScreen = best != null && best.bottom <= height + 0.5;
      if (best == null ||
          (onScreen && (!bestOnScreen || row.bottom > best.bottom)) ||
          (!onScreen && !bestOnScreen && row.bottom < best.bottom)) {
        best = row;
      }
    }
    if (best == null) return null;
    return (key: best.key, offset: height - best.bottom);
  }

  void _reanchor() {
    if (!_scroll.hasClients) return;
    final measured = _measuredAnchor();
    if (measured == null) return;
    final pixels = -measured.offset;
    if (measured.key == _anchor &&
        (_scroll.position.pixels - pixels).abs() < 0.5) {
      return;
    }
    setState(() => _anchor = measured.key);
    _scroll.position.correctPixels(pixels);
  }

  void _jumpToBottom() {
    if (!mounted) return;
    setState(() {
      _anchor = _newestKey;
      _pendingCentre = null;
    });
    _setPixels(0);
  }

  Future<void> _animateToBottom() async {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    // Far away the motion would be a blur of rows; jump instead.
    if (p.pixels - p.minScrollExtent < p.viewportDimension * 3) {
      await _scroll.animateTo(
        p.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    // The bottom was an estimate while rows below were unbuilt.
    _jumpToBottom();
  }

  void _jumpTo(Object key, double offset) {
    if (!_indexOf.containsKey(key)) return;
    setState(() {
      _anchor = key;
      _pendingCentre = null;
    });
    _setPixels(-offset);
    WidgetsBinding.instance.addPostFrameCallback((_) => _settle());
  }

  /// After a jump: back into range if the anchor was placed past the
  /// content (the end of that correction re-anchors), else re-anchor now
  /// so the reader counts as at the bottom when they are.
  void _settle() {
    if (!mounted || !_scroll.hasClients) return;
    final p = _scroll.position;
    if (!p.hasContentDimensions) return;
    final inRange = p.pixels.clamp(p.minScrollExtent, p.maxScrollExtent);
    if (inRange != p.pixels) {
      p.jumpTo(inRange);
      WidgetsBinding.instance.addPostFrameCallback((_) => _settle());
      return;
    }
    _reanchor();
    _scheduleReport();
  }

  void _jumpToFraction(Object key, double fraction) {
    final height = _scroll.hasClients
        ? _scroll.position.viewportDimension
        : (_viewportBox?.size.height ?? 0);
    _jumpTo(key, height * fraction);
  }

  void _centre(Object key) {
    if (!_indexOf.containsKey(key)) return;
    _jumpToFraction(key, 0.5);
    _pendingCentre = key;
    WidgetsBinding.instance.addPostFrameCallback((_) => _finishCentre());
  }

  void _finishCentre() {
    final key = _pendingCentre;
    _pendingCentre = null;
    if (key == null || !mounted || !_scroll.hasClients) return;
    final row = _laidOut().where((r) => r.key == key).firstOrNull;
    if (row == null) return;
    final height = _scroll.position.viewportDimension;
    final want = (height - (row.bottom - row.top)) / 2;
    _jumpTo(key, math.max(0, want));
  }

  void _setPixels(double pixels) {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    // Stop a fling first, or it would overwrite the new offset.
    if (p.isScrollingNotifier.value) p.jumpTo(p.pixels);
    p.correctPixels(pixels);
    _scheduleReport();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    if (n is ScrollStartNotification && n.dragDetails != null) {
      widget.onDragStart?.call();
    }
    if (n is ScrollEndNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scroll.position.isScrollingNotifier.value) {
          _reanchor();
          _scheduleReport();
        }
      });
    }
    _report();
    return false;
  }

  void _scheduleReport() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _report());

  void _report() {
    if (!mounted || !_scroll.hasClients) return;
    final p = _scroll.position;
    if (!p.hasContentDimensions) return;
    if (!p.isScrollingNotifier.value &&
        (p.pixels < p.minScrollExtent || p.pixels > p.maxScrollExtent)) {
      // An anchor placed past the content (a jump near the newest row).
      p.jumpTo(p.pixels.clamp(p.minScrollExtent, p.maxScrollExtent));
    }
    final viewport = _viewportBox;
    final height = viewport?.size.height ?? p.viewportDimension;
    int? newest;
    int? oldest;
    for (final row in _laidOut()) {
      if (row.bottom <= 0 || row.top >= height) continue;
      final index = _indexOf[row.key];
      if (index == null) continue;
      newest = newest == null ? index : math.min(newest, index);
      oldest = oldest == null ? index : math.max(oldest, index);
    }
    final view = AnchoredListView(
      pinned: _anchorIndex == 0 && _isPinned(),
      nearOlderEnd: p.maxScrollExtent - p.pixels < p.viewportDimension * 1.5,
      newestVisible: newest,
      oldestVisible: oldest,
    );
    if (view == _lastView) return;
    _lastView = view;
    widget.onViewChanged?.call(view);
  }

  Widget _row(BuildContext context, int index) {
    final row = widget.rows[index];
    final key = widget.keyOf(row);
    return _RowProbe(
      key: ValueKey(key),
      rowKey: key,
      registry: _built,
      child: widget.itemBuilder(context, row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchor = _anchorIndex;
    final rows = widget.rows;
    int? indexOfKey(Key key, int Function(int) toChild) {
      if (key is! ValueKey) return null;
      final index = _indexOf[key.value];
      if (index == null) return null;
      final child = toChild(index);
      return child < 0 ? null : child;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        key: _viewportKey,
        controller: _scroll,
        reverse: true,
        center: _centerKey,
        physics: const _KeepInRangePhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _row(context, anchor - 1 - i),
              childCount: math.min(anchor, rows.length),
              findChildIndexCallback: (key) =>
                  indexOfKey(key, (index) => anchor - 1 - index),
            ),
          ),
          SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
              (context, i) => _row(context, anchor + i),
              childCount: math.max(0, rows.length - anchor),
              findChildIndexCallback: (key) =>
                  indexOfKey(key, (index) => index - anchor),
            ),
          ),
          if (widget.olderEdge case final edge?)
            SliverToBoxAdapter(child: edge),
        ],
      ),
    );
  }
}

/// Keeps the offset inside the content after rows change while nothing
/// scrolls, instead of springing back into range over several frames.
class _KeepInRangePhysics extends ScrollPhysics {
  const _KeepInRangePhysics({super.parent});

  @override
  _KeepInRangePhysics applyTo(ScrollPhysics? ancestor) =>
      _KeepInRangePhysics(parent: buildParent(ancestor));

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final pixels = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
    if (isScrolling || velocity != 0) return pixels;
    return pixels.clamp(
      newPosition.minScrollExtent,
      newPosition.maxScrollExtent,
    );
  }
}

/// Remembers where each built row is, so the list can find the bottom-most
/// visible one.
class _RowProbe extends StatefulWidget {
  const _RowProbe({
    required this.rowKey,
    required this.registry,
    required this.child,
    super.key,
  });

  final Object rowKey;
  final Map<Object, BuildContext> registry;
  final Widget child;

  @override
  State<_RowProbe> createState() => _RowProbeState();
}

class _RowProbeState extends State<_RowProbe> {
  @override
  void initState() {
    super.initState();
    widget.registry[widget.rowKey] = context;
  }

  @override
  void dispose() {
    if (widget.registry[widget.rowKey] == context) {
      widget.registry.remove(widget.rowKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

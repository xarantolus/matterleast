import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/anchored_scrollbar.dart';
import 'package:matterleast/ui/motion.dart';

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

  AnchoredPosition? _atRest;

  /// The bottom-most visible row and where it sits, to restore later. Once
  /// the list is gone, where it last came to rest.
  AnchoredPosition? get position => _state?._measuredAnchor() ?? _atRest;

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
/// insertion shifts the origin. When scrolling settles, and when rows change
/// while the reader scrolls, the row above the topmost visible one becomes
/// the anchor, so the top edge of what the reader sees stays put and a
/// visible row that grows pushes the rows below it down. A reader at the newest row instead stays pinned to the bottom.
/// The offset is rewritten in the same frame, so re-anchoring moves nothing.
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

  /// Keeps the top edge of the row around [context] in place through its
  /// next change of height, so it grows or shrinks downwards. Call it just
  /// before the change. With [unlessAbove], a row whose top is above the
  /// screen keeps its bottom edge instead, so a shrinking row comes into
  /// view from above.
  static void keepTopOf(BuildContext context, {bool unlessAbove = false}) {
    final probe = context.findAncestorStateOfType<_RowProbeState>();
    if (probe == null) return;
    probe.widget.list._keepTop(probe.widget.rowKey, unlessAbove: unlessAbove);
  }
}

/// The anchor when the oldest row's top edge is the fixed one.
const _pastOldest = Object();

class _AnchoredListState<T> extends State<AnchoredList<T>> {
  static const pinTolerance = 48.0;

  late final ScrollController _scroll;
  final _centerKey = GlobalKey();
  final _edgeKey = GlobalKey();
  // Desktop has no overscroll: a pulled-past list would leave the screen.
  late final _physics = _KeepInRangePhysics(
    oldestTop: _oldestTop,
    parent: isDesktop ? const ClampingScrollPhysics() : null,
  );

  /// The offset at which the oldest content's top edge meets the top of the
  /// screen. The viewport never reports a maximum below zero, so when less
  /// than a screen of content lies above the anchor it would let the reader
  /// scroll on until that content sits at the bottom of an empty list.
  double? _oldestTop() {
    if (!_scroll.hasClients) return null;
    final p = _scroll.position;
    if (!p.hasContentDimensions) return null;
    double extentOf(BuildContext? context) {
      final sliver = context?.findRenderObject() as RenderSliver?;
      return sliver?.geometry?.scrollExtent ?? 0;
    }

    final above =
        extentOf(_centerKey.currentContext) + extentOf(_edgeKey.currentContext);
    final top = math.max(p.minScrollExtent, above - p.viewportDimension);
    // An opened row grows downwards, even into a short list's space above
    // its oldest row.
    if (_openedAt case (:final anchor, :final pixels) when anchor == _anchor) {
      if (!_splitPending && p.pixels <= top + 0.5) {
        _openedAt = null;
      } else {
        return math.max(top, pixels);
      }
    }
    return top;
  }

  /// The view's position when a row was opened, under its anchor.
  ({Object? anchor, double pixels})? _openedAt;

  double get _maxPixels {
    final p = _scroll.position;
    return math.min(p.maxScrollExtent, _oldestTop() ?? p.maxScrollExtent);
  }

  final _viewportKey = GlobalKey();
  final _span = ValueNotifier<RowSpan?>(null);
  final _built = <Object, BuildContext>{};
  var _indexOf = <Object, int>{};
  Object? _anchor;
  Object? _pendingCentre;
  AnchoredListView? _lastView;

  /// The reader is scrolling, by a drag or the fling after it.
  var _dragging = false;

  /// The anchor moved and the rows haven't been laid out around it yet.
  var _splitPending = false;

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
    _watchShifts();
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
    final idle =
        !_scroll.hasClients || !_scroll.position.isScrollingNotifier.value;
    // Anchored at the newest row's bottom edge is at the bottom by
    // construction. Measuring isn't enough: right after a jump from far up
    // the rows are still laid out where they were, and a row sent with the
    // jump would land below the screen.
    final atBottom =
        _anchor != null &&
        _anchor == oldNewest &&
        _scroll.hasClients &&
        _scroll.position.pixels <= pinTolerance;
    final wasPinned = idle && (atBottom || _isPinned(oldNewest));
    _indexRows();
    final newest = _newestKey;
    if (_anchor == null || (wasPinned && newest != oldNewest)) {
      // A new row entered at the bottom under a reader who is there: it
      // becomes the anchor at the bottom edge, so the list lifts.
      if (_scroll.hasClients && _anchor != null) {
        _moved('new newest row while pinned', 0, shifts: false);
        _scroll.position.correctPixels(0);
      }
      _anchor = newest;
    } else if (_anchor != _pastOldest && !_indexOf.containsKey(_anchor)) {
      _anchor = _survivor(old.rows, old.keyOf, oldIndex);
    } else if (_keptRow(old.rows.map(old.keyOf).toList(), oldIndex)
        case final kept?) {
      _keepBottomOf(kept);
    } else if (_dragging) {
      // The anchor is where the reader started scrolling; a row changing
      // height between it and the screen would move what they look at.
      _reanchor();
    }
    _scheduleReport();
  }

  /// When rows were inserted right below the anchor, they would push the
  /// reader's rows down: older rows arriving while the reader is at the
  /// oldest one, or a day separator moving up above them. The row that
  /// stays put instead is the first one, from the row below the anchor
  /// towards the newest, whose newer neighbour is unchanged.
  Object? _keptRow(List<Object> oldKeys, Map<Object, int> oldIndex) {
    final anchor = _anchor;
    final oldAt = anchor == _pastOldest ? oldKeys.length : oldIndex[anchor];
    final newAt = _anchorIndex;
    if (oldAt == null || oldAt == 0) return null;
    final newKeys = [for (final row in widget.rows) widget.keyOf(row)];
    for (var i = oldAt - 1; i >= 0; i--) {
      final at = _indexOf[oldKeys[i]];
      if (at == null) continue;
      final newer = at > 0 ? newKeys[at - 1] : null;
      if (newer != (i > 0 ? oldKeys[i - 1] : null)) continue;
      final unchanged = i == oldAt - 1 && at == newAt - 1;
      return unchanged ? null : oldKeys[i];
    }
    return null;
  }

  /// Anchors at row [key] so its bottom edge stays where it is drawn now; a
  /// change of its height, such as a header it loses to the rows above,
  /// goes upwards.
  void _keepBottomOf(Object key) {
    final height = _viewportHeight;
    final row = _rowAt(key);
    if (height == null || row == null) return;
    _moved('kept row ${_indexOf[key]} in place', 0, shifts: false);
    _anchor = key;
    // A running fling goes on from here: it restarts on the new extents.
    _scroll.position.correctPixels(row.bottom - height);
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _scroll.dispose();
    _span.dispose();
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

  /// The reader is at the bottom: the newest row is laid out and its
  /// bottom edge is within [pinTolerance] of the list's bottom. Decided
  /// from where rows were drawn, which a re-anchoring doesn't change,
  /// rather than from extents, which lag one layout behind it.
  bool _isPinned([Object? newest]) {
    if (!_scroll.hasClients) return true;
    final key = newest ?? _newestKey;
    final height = _viewportHeight;
    if (key == null || height == null) return true;
    final row = _rowAt(key);
    if (row == null) return false;
    return row.bottom - height <= pinTolerance;
  }

  int get _anchorIndex =>
      _anchor == _pastOldest ? widget.rows.length : (_indexOf[_anchor] ?? 0);

  double? get _viewportHeight {
    final viewport = _viewportBox;
    return viewport != null && viewport.hasSize ? viewport.size.height : null;
  }

  ({Object key, double top, double bottom})? _rowAt(Object key) {
    final viewport = _viewportBox;
    final box = _built[key]?.findRenderObject() as RenderBox?;
    if (viewport == null || box == null || !box.attached || !box.hasSize) {
      return null;
    }
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    return (key: key, top: top, bottom: top + box.size.height);
  }

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

  /// The anchor that keeps the reader's view in place, and the offset that
  /// leaves everything where it is drawn now: the newest row at the bottom
  /// for a pinned reader, else the row above the topmost visible one, so
  /// that one's top edge is the fixed point.
  ({Object key, double pixels})? _readingAnchor() {
    final height = _viewportHeight;
    final newest = _newestKey;
    if (height == null || newest == null) return null;
    if (_isPinned()) {
      final row = _rowAt(newest);
      if (row != null) return (key: newest, pixels: row.bottom - height);
    }
    ({Object key, double top, double bottom})? top;
    ({Object key, double top, double bottom})? tall;
    for (final row in _laidOut()) {
      if (row.bottom <= 0 || row.top >= height) continue;
      if (row.top >= 0) {
        if (top == null || row.top < top.top) top = row;
      } else {
        tall = row;
      }
    }
    if (top == null) {
      // One row fills the screen; it keeps its bottom edge.
      if (tall == null) return null;
      return (key: tall.key, pixels: tall.bottom - height);
    }
    return _aboveOf(top.key, top.top - height);
  }

  /// The anchor whose bottom edge is the top edge of row [key].
  ({Object key, double pixels})? _aboveOf(Object key, double pixels) {
    final index = _indexOf[key];
    if (index == null) return null;
    final older = index + 1 < widget.rows.length
        ? widget.keyOf(widget.rows[index + 1])
        : _pastOldest;
    return (key: older, pixels: pixels);
  }

  void _setAnchor(({Object key, double pixels}) to) {
    final p = _scroll.position;
    if (to.key == _anchor && (p.pixels - to.pixels).abs() < 0.5) return;
    setState(() => _anchor = to.key);
    p.correctPixels(to.pixels);
    // Extents are those of the old split until the next layout; measured
    // against them, the new offset would look out of range.
    _splitPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splitPending = false;
      _report();
    });
  }

  void _reanchor() {
    if (!_scroll.hasClients) return;
    if (_readingAnchor() case final to?) _setAnchor(to);
  }

  void _keepTop(Object key, {required bool unlessAbove}) {
    if (!mounted || !_scroll.hasClients) return;
    final height = _viewportHeight;
    final row = _rowAt(key);
    if (height == null || row == null) return;
    // The reader asked for this row to change; what moves below is wanted.
    _resizingUntil = DateTime.now().add(const Duration(milliseconds: 400));
    if (unlessAbove && row.top < 0) {
      _setAnchor((key: key, pixels: row.bottom - height));
    } else if (_aboveOf(key, row.top - height) case final to?) {
      _setAnchor(to);
      _openedAt = (anchor: to.key, pixels: to.pixels);
    }
  }

  // Debug only: every programmatic move of the list, and any frame in which
  // what the reader sees moved without a scroll, go to the log.
  var _jumps = 0;
  var _intended = false;
  var _resizingUntil = DateTime(0);
  ({Object key, double top})? _lastTop;

  void _moved(String reason, double to, {bool shifts = true}) {
    if (!kDebugMode) return;
    _intended = true;
    if (!shifts) return;
    _jumps++;
    final from = _scroll.hasClients ? _scroll.position.pixels : 0.0;
    debugPrint(
      'anchored_list: move #$_jumps $reason '
      '${from.toStringAsFixed(1)} -> ${to.toStringAsFixed(1)} '
      'anchor $_anchorIndex of ${widget.rows.length}',
    );
  }

  void _watchShifts() {
    if (!kDebugMode || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrolling =
          _scroll.hasClients && _scroll.position.isScrollingNotifier.value;
      final last = _lastTop;
      final resizing = DateTime.now().isBefore(_resizingUntil);
      if (!scrolling &&
          !_intended &&
          !resizing &&
          last != null &&
          !_isPinned()) {
        final now = _rowAt(last.key);
        if (now != null && (now.top - last.top).abs() > 0.5) {
          _jumps++;
          debugPrint(
            'anchored_list: SHIFT #$_jumps visible row moved '
            '${(now.top - last.top).toStringAsFixed(1)} px without a scroll',
          );
        }
      }
      _intended = false;
      _lastTop = scrolling ? null : _topVisible();
      _watchShifts();
    });
  }

  ({Object key, double top})? _topVisible() {
    final height = _viewportHeight;
    if (height == null) return null;
    ({Object key, double top})? best;
    for (final row in _laidOut()) {
      if (row.top < 0 || row.top >= height) continue;
      if (best == null || row.top < best.top) {
        best = (key: row.key, top: row.top);
      }
    }
    return best;
  }

  void _jumpToBottom() {
    if (!mounted) return;
    _moved('to the bottom', 0);
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
        duration: motion(context, const Duration(milliseconds: 300)),
        curve: Curves.easeOutCubic,
      );
    }
    // The bottom was an estimate while rows below were unbuilt.
    _jumpToBottom();
  }

  void _jumpTo(Object key, double offset) {
    if (!_indexOf.containsKey(key)) return;
    _moved('to row ${_indexOf[key]}', -offset);
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
    final inRange = p.pixels.clamp(p.minScrollExtent, _maxPixels);
    if (inRange != p.pixels) {
      _moved('back into range after a jump', inRange);
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
    if (n is ScrollUpdateNotification) _intended = true;
    if (n is ScrollStartNotification) {
      _dragging = n.dragDetails != null;
      if (_dragging) widget.onDragStart?.call();
    }
    if (n is ScrollEndNotification) {
      _dragging = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scroll.position.isScrollingNotifier.value) {
          _reanchor();
          _scheduleReport();
        }
      });
    }
    // Notifications can come in the middle of a layout, when rows can't be
    // measured yet.
    _scheduleReport();
    return false;
  }

  var _reportScheduled = false;

  void _scheduleReport() {
    if (_reportScheduled) return;
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      _report();
    });
  }

  void _report() {
    if (!mounted || !_scroll.hasClients || _splitPending) return;
    final p = _scroll.position;
    if (!p.hasContentDimensions) return;
    if (!p.isScrollingNotifier.value &&
        (p.pixels < p.minScrollExtent || p.pixels > _maxPixels)) {
      // An anchor placed past the content (a jump near the newest row).
      _moved(
        'clamped into range',
        p.pixels.clamp(p.minScrollExtent, _maxPixels),
      );
      p.jumpTo(p.pixels.clamp(p.minScrollExtent, _maxPixels));
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
    if (isDesktop) _span.value = _spanOf(newest, oldest, height);
    // The rows can't be measured once the list is being torn down.
    if (!p.isScrollingNotifier.value) {
      widget.controller._atRest = _measuredAnchor();
    }
    final view = AnchoredListView(
      pinned: _isPinned(),
      nearOlderEnd: _maxPixels - p.pixels < p.viewportDimension * 1.5,
      newestVisible: newest,
      oldestVisible: oldest,
    );
    if (view == _lastView) return;
    _lastView = view;
    widget.onViewChanged?.call(view);
  }

  /// The rows on screen counted from the oldest, partly shown ones in part;
  /// null before any row is laid out.
  RowSpan? _spanOf(int? newest, int? oldest, double height) {
    if (newest == null || oldest == null) return null;
    final first = _rowAt(widget.keyOf(widget.rows[oldest]));
    final last = _rowAt(widget.keyOf(widget.rows[newest]));
    if (first == null || last == null) return null;
    final total = widget.rows.length;
    double share(double hidden, double rowHeight) =>
        rowHeight <= 0 ? 0 : (hidden / rowHeight).clamp(0, 1);
    final start =
        total - 1 - oldest + share(-first.top, first.bottom - first.top);
    final end =
        total - newest - share(last.bottom - height, last.bottom - last.top);
    return RowSpan(start: start, extent: end - start, total: total);
  }

  /// Shows row [fromOldest] (0 is the oldest) at the top, for a dragged
  /// scrollbar; the list puts it back in range if that leaves a gap.
  void _showRowAtTop(int fromOldest) {
    final rows = widget.rows;
    final height = _viewportHeight;
    if (rows.isEmpty || height == null) return;
    // The row above is parked just off the top edge.
    final above = rows[rows.length - fromOldest];
    final key = widget.keyOf(fromOldest == 0 ? rows.last : above);
    _jumpTo(key, fromOldest == 0 ? height - 1 : height);
  }

  Widget _row(BuildContext context, int index) {
    final row = widget.rows[index];
    final key = widget.keyOf(row);
    return _RowProbe(
      key: ValueKey(key),
      rowKey: key,
      list: this as _AnchoredListState<Object?>,
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

    final scrollView = CustomScrollView(
      key: _viewportKey,
      controller: _scroll,
      reverse: true,
      center: _centerKey,
      physics: _physics,
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
          SliverToBoxAdapter(key: _edgeKey, child: edge),
      ],
    );
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: isDesktop
          ? Stack(
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: scrollView,
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: AnchoredScrollbar.width,
                  child: AnchoredScrollbar(span: _span, onRow: _showRowAtTop),
                ),
              ],
            )
          : scrollView,
    );
  }
}

/// Keeps the offset inside the content: after rows change while nothing
/// scrolls (instead of springing back over several frames), and at the
/// oldest content's real top edge, which the viewport doesn't report.
class _KeepInRangePhysics extends ScrollPhysics {
  const _KeepInRangePhysics({required this.oldestTop, super.parent});

  final double? Function() oldestTop;

  @override
  _KeepInRangePhysics applyTo(ScrollPhysics? ancestor) =>
      _KeepInRangePhysics(oldestTop: oldestTop, parent: buildParent(ancestor));

  ScrollMetrics _withTop(ScrollMetrics position) {
    final top = oldestTop();
    if (top == null || top >= position.maxScrollExtent) return position;
    return position.copyWith(maxScrollExtent: top);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      super.applyBoundaryConditions(_withTop(position), value);

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) => super.createBallisticSimulation(_withTop(position), velocity);

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
    final range = _withTop(newPosition);
    return pixels.clamp(range.minScrollExtent, range.maxScrollExtent);
  }
}

/// Remembers where each built row is, so the list can find the bottom-most
/// visible one.
class _RowProbe extends StatefulWidget {
  const _RowProbe({
    required this.rowKey,
    required this.list,
    required this.child,
    super.key,
  });

  final Object rowKey;
  final _AnchoredListState<Object?> list;
  final Widget child;

  @override
  State<_RowProbe> createState() => _RowProbeState();
}

class _RowProbeState extends State<_RowProbe> {
  @override
  void initState() {
    super.initState();
    widget.list._built[widget.rowKey] = context;
  }

  @override
  void dispose() {
    final built = widget.list._built;
    if (built[widget.rowKey] == context) built.remove(widget.rowKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

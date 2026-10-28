import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/motion.dart';

/// What a list shows, counted in rows from the oldest: it starts [start]
/// rows in (a part of a row counts as a part) and covers [extent] rows of
/// [total]. Row counts don't change while rows are measured, so a thumb
/// drawn from them doesn't jump.
@immutable
class RowSpan {
  const RowSpan({
    required this.start,
    required this.extent,
    required this.total,
  });

  final double start;
  final double extent;
  final int total;

  /// Everything fits, so there is nothing to scroll.
  bool get fits => extent >= total - 0.001;

  @override
  bool operator ==(Object other) =>
      other is RowSpan &&
      other.start == start &&
      other.extent == extent &&
      other.total == total;

  @override
  int get hashCode => Object.hash(start, extent, total);
}

/// Pure: the thumb's top and height on a track of [track] pixels. The thumb
/// is at least [minThumb] tall, and reaches the track's end exactly when the
/// span reaches the last row.
({double top, double height}) thumbGeometry(
  RowSpan span,
  double track, {
  required double minThumb,
}) {
  final height = math.min(
    track,
    math.max(minThumb, track * span.extent / span.total),
  );
  final scrollable = span.total - span.extent;
  final share = scrollable <= 0 ? 0.0 : (span.start / scrollable).clamp(0, 1);
  return (top: share * (track - height), height: height);
}

/// Pure: the row, counted from the oldest, a drag that holds the thumb at
/// [thumbTop] asks for at the top of the screen.
int rowAtThumbTop(
  RowSpan span,
  double track,
  double thumbTop, {
  required double minThumb,
}) {
  final thumb = thumbGeometry(span, track, minThumb: minThumb);
  final room = track - thumb.height;
  final share = room <= 0 ? 0.0 : (thumbTop / room).clamp(0.0, 1.0);
  final row = (share * (span.total - span.extent)).floor();
  return row.clamp(0, span.total - 1);
}

/// A thin scrollbar for an anchored list, drawn from [span] and shown only
/// while the list moves or the pointer is near. Dragging it asks
/// [onRow] for the row, counted from the oldest, to show at the top.
class AnchoredScrollbar extends StatefulWidget {
  const AnchoredScrollbar({required this.span, required this.onRow, super.key});

  final ValueListenable<RowSpan?> span;
  final ValueChanged<int> onRow;

  static const width = 14.0;
  static const minThumb = 36.0;

  @override
  State<AnchoredScrollbar> createState() => _AnchoredScrollbarState();
}

class _AnchoredScrollbarState extends State<AnchoredScrollbar> {
  static const _idle = Duration(milliseconds: 1000);

  Timer? _hide;
  var _awake = false;
  var _hovered = false;

  /// While dragging, the thumb's top as the pointer holds it.
  double? _dragTop;
  double _grab = 0;
  RowSpan? _last;

  @override
  void initState() {
    super.initState();
    widget.span.addListener(_moved);
  }

  @override
  void didUpdateWidget(AnchoredScrollbar old) {
    super.didUpdateWidget(old);
    if (old.span != widget.span) {
      old.span.removeListener(_moved);
      widget.span.addListener(_moved);
    }
  }

  @override
  void dispose() {
    widget.span.removeListener(_moved);
    _hide?.cancel();
    super.dispose();
  }

  void _moved() {
    final span = widget.span.value;
    if (span == _last) return;
    // The first span after the list opens isn't movement.
    final first = _last == null;
    _last = span;
    if (first) return;
    _wake();
  }

  void _wake() {
    _hide?.cancel();
    _hide = Timer(_idle, () {
      if (mounted) setState(() => _awake = false);
    });
    if (!_awake) setState(() => _awake = true);
  }

  void _drag(RowSpan span, double track, double top) {
    final thumb = thumbGeometry(
      span,
      track,
      minThumb: AnchoredScrollbar.minThumb,
    );
    final clamped = top.clamp(0.0, track - thumb.height);
    setState(() => _dragTop = clamped);
    widget.onRow(
      rowAtThumbTop(span, track, clamped, minThumb: AnchoredScrollbar.minThumb),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<RowSpan?>(
    valueListenable: widget.span,
    builder: (context, span, _) {
      if (span == null || span.fits) return const SizedBox.shrink();
      return LayoutBuilder(
        builder: (context, constraints) {
          final track = constraints.maxHeight;
          final thumb = thumbGeometry(
            span,
            track,
            minThumb: AnchoredScrollbar.minThumb,
          );
          final top = _dragTop ?? thumb.top;
          final visible = _awake || _hovered || _dragTop != null;
          final scheme = Theme.of(context).colorScheme;
          return MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (d) {
                final y = d.localPosition.dy;
                final onThumb = y >= top && y <= top + thumb.height;
                _grab = onThumb ? y - top : thumb.height / 2;
                _drag(span, track, y - _grab);
              },
              onVerticalDragUpdate: (d) =>
                  _drag(span, track, d.localPosition.dy - _grab),
              onVerticalDragEnd: (_) => setState(() => _dragTop = null),
              onVerticalDragCancel: () => setState(() => _dragTop = null),
              onTapDown: (d) {
                final y = d.localPosition.dy;
                if (y >= top && y <= top + thumb.height) return;
                _drag(span, track, y - thumb.height / 2);
                setState(() => _dragTop = null);
              },
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: motion(context, const Duration(milliseconds: 150)),
                child: Stack(
                  children: [
                    Positioned(
                      top: top,
                      height: thumb.height,
                      right: 3,
                      width: _hovered || _dragTop != null ? 8 : 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withValues(
                            alpha: _dragTop != null ? 0.55 : 0.38,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

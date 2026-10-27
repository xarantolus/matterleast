import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/pane_widths.dart';
import 'package:matterleast/domain/panes.dart';

enum _Pane { list, thread }

/// The wide layout's row: [list] (the rail and the channel list), the
/// conversation [main] and, when open, the thread pane [side], with a
/// divider to drag between each. [listInset] and [sideInset] are the
/// fixed parts of the list's and the thread pane's boxes (the rail, the
/// window's insets). Dragging only lays the panes out again; the widths
/// are saved when a drag ends or a divider is reset or stepped.
class ResizablePanes extends ConsumerStatefulWidget {
  const ResizablePanes({
    required this.list,
    required this.main,
    required this.side,
    required this.defaultListWidth,
    this.listInset = 0,
    this.sideInset = 0,
    super.key,
  });

  final Widget list;
  final Widget main;
  final Widget? side;
  final double defaultListWidth;
  final double listInset;
  final double sideInset;

  @override
  ConsumerState<ResizablePanes> createState() => _ResizablePanesState();
}

class _ResizablePanesState extends ConsumerState<ResizablePanes> {
  late final _widths = ValueNotifier(
    ref.read(paneWidthsProvider).value ?? const PaneWidths(),
  );
  var _room = 0.0;
  var _dragging = false;
  var _dragStart = 0.0;
  var _dragOffset = 0.0;

  bool get _hasSide => widget.side != null;

  @override
  void dispose() {
    _widths.dispose();
    super.dispose();
  }

  ({double list, double? thread}) _fitted(PaneWidths widths) => fitPanes(
    room: _room,
    list:
        (_hasSide ? widths.listBesideThread : widths.list) ??
        widget.defaultListWidth,
    thread: _hasSide ? widths.thread ?? threadPaneWidth : null,
  );

  double _shown(_Pane pane) {
    final fitted = _fitted(_widths.value);
    return switch (pane) {
      _Pane.list => fitted.list,
      _Pane.thread => fitted.thread ?? 0,
    };
  }

  PaneWidths _set(_Pane pane, double? width) {
    final widths = _widths.value;
    return switch (pane) {
      _Pane.list when _hasSide => widths.copyWith(listBesideThread: width),
      _Pane.list => widths.copyWith(list: width),
      _Pane.thread => widths.copyWith(thread: width),
    };
  }

  void _resizeTo(_Pane pane, double wanted) {
    final other = _shown(pane == _Pane.list ? _Pane.thread : _Pane.list);
    _widths.value = _set(
      pane,
      resizedPane(
        wanted,
        room: _room,
        others: other,
        isThread: pane == _Pane.thread,
      ),
    );
  }

  void _dragStarted(_Pane pane) {
    _dragging = true;
    _dragStart = _shown(pane);
    _dragOffset = 0;
  }

  void _dragged(_Pane pane, double dx) {
    _dragOffset += dx;
    // The thread pane grows as its divider moves left.
    final sign = pane == _Pane.list ? 1 : -1;
    _resizeTo(pane, _dragStart + sign * _dragOffset);
  }

  void _save() => unawaited(
    ref.read(settingsStoreProvider).write(Settings.paneWidths, _widths.value),
  );

  void _dragEnded() {
    _dragging = false;
    _save();
  }

  void _step(_Pane pane, double by) {
    _resizeTo(pane, _shown(pane) + by);
    _save();
  }

  void _reset(_Pane pane) {
    _widths.value = _set(pane, null);
    _save();
  }

  _PaneDivider _divider(_Pane pane, double width) {
    final sign = pane == _Pane.list ? 1 : -1;
    return _PaneDivider(
      label: pane == _Pane.list ? 'Channel list width' : 'Thread width',
      width: width,
      onDragStart: () => _dragStarted(pane),
      onDragUpdate: (dx) => _dragged(pane, dx),
      onDragEnd: _dragEnded,
      onReset: () => _reset(pane),
      onWider: () => _step(pane, paneWidthStep),
      onNarrower: () => _step(pane, -paneWidthStep),
      onMove: (right) => _step(pane, sign * (right ? 1 : -1) * paneWidthStep),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(paneWidthsProvider, (_, next) {
      if (next.value case final stored? when !_dragging) {
        _widths.value = stored;
      }
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        final dividers = _hasSide ? 2 : 1;
        _room =
            constraints.maxWidth -
            widget.listInset -
            (_hasSide ? widget.sideInset : 0) -
            dividers;
        return ValueListenableBuilder(
          valueListenable: _widths,
          builder: (context, widths, _) {
            final fitted = _fitted(widths);
            final listEnd = widget.listInset + fitted.list;
            final thread = fitted.thread;
            final side = widget.side;
            final threadStart = thread == null
                ? null
                : constraints.maxWidth - widget.sideInset - thread - 1;
            final hit = _PaneDivider.hitWidth;
            return Stack(
              children: [
                Row(
                  children: [
                    SizedBox(width: listEnd, child: widget.list),
                    const _Line(),
                    Expanded(child: widget.main),
                    if (side != null && thread != null) ...[
                      const _Line(),
                      SizedBox(width: thread + widget.sideInset, child: side),
                    ],
                  ],
                ),
                Positioned(
                  left: listEnd + 0.5 - hit / 2,
                  width: hit,
                  top: 0,
                  bottom: 0,
                  child: _divider(_Pane.list, fitted.list),
                ),
                if (threadStart != null && thread != null)
                  Positioned(
                    left: threadStart + 0.5 - hit / 2,
                    width: hit,
                    top: 0,
                    bottom: 0,
                    child: _divider(_Pane.thread, thread),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// The one-pixel gap a divider is drawn in.
class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 1);
}

class _PaneDivider extends StatefulWidget {
  const _PaneDivider({
    required this.label,
    required this.width,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onReset,
    required this.onWider,
    required this.onNarrower,
    required this.onMove,
  });

  /// A mouse needs little room; a finger gets a wider target than the line.
  static double get hitWidth => isDesktop ? 8 : 24;

  final String label;
  final double width;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onReset;
  final VoidCallback onWider;
  final VoidCallback onNarrower;

  /// The divider moves right (true) or left by one step.
  final ValueChanged<bool> onMove;

  @override
  State<_PaneDivider> createState() => _PaneDividerState();
}

class _PaneDividerState extends State<_PaneDivider> {
  var _hovered = false;
  var _focused = false;
  var _dragging = false;

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        widget.onMove(true);
      case LogicalKeyboardKey.arrowLeft:
        widget.onMove(false);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = _dragging || _focused;
    final color = active
        ? colors.primary
        : _hovered
        ? colors.outline
        : DividerTheme.of(context).color ?? colors.outlineVariant;
    final shown = widget.width.round();
    final step = paneWidthStep.round();
    return Semantics(
      slider: true,
      label: widget.label,
      value: '$shown',
      increasedValue: '${shown + step}',
      decreasedValue: '${shown - step}',
      onIncrease: widget.onWider,
      onDecrease: widget.onNarrower,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: _key,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            // The divider stays under the pointer from the first pixel.
            dragStartBehavior: DragStartBehavior.down,
            onHorizontalDragStart: (_) {
              setState(() => _dragging = true);
              widget.onDragStart();
            },
            onHorizontalDragUpdate: (d) => widget.onDragUpdate(d.delta.dx),
            onHorizontalDragEnd: (_) {
              setState(() => _dragging = false);
              widget.onDragEnd();
            },
            onHorizontalDragCancel: () {
              if (!_dragging) return;
              setState(() => _dragging = false);
              widget.onDragEnd();
            },
            onDoubleTap: widget.onReset,
            child: Center(
              child: SizedBox(
                width: active || _hovered ? 3 : 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

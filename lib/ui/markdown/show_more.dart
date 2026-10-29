import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/tokens.dart';

/// Space the "Show more" control needs; collapsing saves less than this is
/// pointless.
const showMoreAllowance = 54.0;

/// Pure: the height a message body of [contentHeight] is cut to on a screen
/// [screenHeight] tall (or at [limit]), or null when it is shown whole.
double? collapsedHeight(
  double contentHeight,
  double screenHeight, {
  double? limit,
}) {
  final cut = limit ?? screenHeight * 0.5;
  return contentHeight > cut + showMoreAllowance ? cut : null;
}

/// The messages a conversation shows expanded, kept above the rows so a
/// row that is built again stays expanded.
class ShowMoreMemory extends InheritedWidget {
  const ShowMoreMemory({
    required this.expanded,
    required super.child,
    super.key,
  });

  final Set<String> expanded;

  static Set<String>? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ShowMoreMemory>()?.expanded;

  @override
  bool updateShouldNotify(ShowMoreMemory old) => expanded != old.expanded;
}

/// Shows [child] whole, or cut at half the screen (or [limit]) with
/// "Show more" over a
/// fade at the bottom. The cut height is decided in layout, so the row
/// never changes height after it is first laid out. Expanding and
/// collapsing animate and keep the message's top edge in place.
class ShowMore extends StatefulWidget {
  const ShowMore({
    required this.id,
    required this.child,
    this.limit,
    super.key,
  });

  /// Remembers the expanded state under this name in [ShowMoreMemory].
  final String id;
  final Widget child;
  final double? limit;

  @override
  State<ShowMore> createState() => _ShowMoreState();
}

class _ShowMoreState extends State<ShowMore>
    with SingleTickerProviderStateMixin {
  late var _expanded = ShowMoreMemory.of(context)?.contains(widget.id) ?? false;
  var _cut = false;
  AnimationController? _opening;

  @override
  void dispose() {
    _opening?.dispose();
    super.dispose();
  }

  void _onCut(bool cut) {
    if (cut == _cut) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _cut = cut);
    });
  }

  void _toggle() {
    final expand = !_expanded;
    AnchoredList.keepTopOf(context, unlessAbove: !expand);
    final memory = ShowMoreMemory.of(context);
    if (expand) {
      memory?.add(widget.id);
    } else {
      memory?.remove(widget.id);
    }
    final opening = _opening ??= AnimationController(
      vsync: this,
      duration: context.density.expand,
      value: _expanded ? 1 : 0,
    )..addListener(() => setState(() {}));
    if (MediaQuery.disableAnimationsOf(context)) {
      opening.value = expand ? 1 : 0;
    } else if (expand) {
      opening.forward();
    } else {
      opening.reverse();
    }
    setState(() => _expanded = expand);
  }

  @override
  Widget build(BuildContext context) {
    final page = Theme.of(context).scaffoldBackgroundColor;
    final open = Curves.easeOutCubic.transform(
      _opening?.value ?? (_expanded ? 1 : 0),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            _CutToHeight(
              screenHeight: MediaQuery.sizeOf(context).height,
              limit: widget.limit,
              open: open,
              onCut: _onCut,
              child: widget.child,
            ),
            if (_cut && !_expanded)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [page.withValues(alpha: 0), page, page],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: Spacing.xl),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: context.tokens.accent,
                        ),
                        onPressed: _toggle,
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Show more'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_expanded)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _toggle,
              icon: const Icon(Icons.expand_less),
              label: const Text('Show less'),
            ),
          ),
      ],
    );
  }
}

class _CutToHeight extends SingleChildRenderObjectWidget {
  const _CutToHeight({
    required this.screenHeight,
    required this.limit,
    required this.open,
    required this.onCut,
    required super.child,
  });

  final double screenHeight;
  final double? limit;

  /// 0 cut, 1 whole, between while it opens or closes.
  final double open;
  final ValueChanged<bool> onCut;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCutToHeight(screenHeight, limit, open, onCut);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCutToHeight renderObject,
  ) {
    renderObject
      ..screenHeight = screenHeight
      ..limit = limit
      ..open = open
      ..onCut = onCut;
  }
}

class _RenderCutToHeight extends RenderProxyBox {
  _RenderCutToHeight(this._screenHeight, this._limit, this._open, this.onCut);

  double _screenHeight;
  double? _limit;
  double _open;
  ValueChanged<bool> onCut;
  var _clipped = false;

  set screenHeight(double value) {
    if (value == _screenHeight) return;
    _screenHeight = value;
    markNeedsLayout();
  }

  set limit(double? value) {
    if (value == _limit) return;
    _limit = value;
    markNeedsLayout();
  }

  set open(double value) {
    if (value == _open) return;
    _open = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );
    final full = child.size.height;
    final cut = collapsedHeight(full, _screenHeight, limit: _limit);
    final height = cut == null ? full : cut + (full - cut) * _open;
    _clipped = height < full;
    size = constraints.constrain(Size(child.size.width, height));
    onCut(cut != null);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_clipped) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      (!_clipped || (Offset.zero & size).contains(position)) &&
      super.hitTestChildren(result, position: position);
}

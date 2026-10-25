import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// Space the "Show more" control needs; collapsing saves less than this is
/// pointless.
const showMoreAllowance = 54.0;

/// Pure: the height a message body of [contentHeight] is cut to on a screen
/// [screenHeight] tall, or null when it is shown whole.
double? collapsedHeight(double contentHeight, double screenHeight) {
  final limit = screenHeight * 0.5;
  return contentHeight > limit + showMoreAllowance ? limit : null;
}

/// Shows [child] whole, or cut at half the screen with "Show more" over a
/// fade at the bottom. The cut height is decided in layout, so the row
/// never changes height after it is first laid out; expanding grows it
/// downwards only.
class ShowMore extends StatefulWidget {
  const ShowMore({required this.child, super.key});

  final Widget child;

  @override
  State<ShowMore> createState() => _ShowMoreState();
}

class _ShowMoreState extends State<ShowMore> {
  var _expanded = false;
  var _cut = false;

  void _onCut(bool cut) {
    if (cut == _cut) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _cut = cut);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.child,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = false),
              icon: const Icon(Icons.expand_less),
              label: const Text('Show less'),
            ),
          ),
        ],
      );
    }
    final page = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: [
        _CutToHeight(
          screenHeight: MediaQuery.sizeOf(context).height,
          onCut: _onCut,
          child: widget.child,
        ),
        if (_cut)
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
                    onPressed: () => setState(() => _expanded = true),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Show more'),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CutToHeight extends SingleChildRenderObjectWidget {
  const _CutToHeight({
    required this.screenHeight,
    required this.onCut,
    required super.child,
  });

  final double screenHeight;
  final ValueChanged<bool> onCut;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCutToHeight(screenHeight, onCut);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCutToHeight renderObject,
  ) {
    renderObject
      ..screenHeight = screenHeight
      ..onCut = onCut;
  }
}

class _RenderCutToHeight extends RenderProxyBox {
  _RenderCutToHeight(this._screenHeight, this.onCut);

  double _screenHeight;
  ValueChanged<bool> onCut;
  var _clipped = false;

  set screenHeight(double value) {
    if (value == _screenHeight) return;
    _screenHeight = value;
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
    final cut = collapsedHeight(child.size.height, _screenHeight);
    _clipped = cut != null;
    size = constraints.constrain(
      Size(child.size.width, cut ?? child.size.height),
    );
    onCut(_clipped);
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

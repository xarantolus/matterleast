/// The zoom steps of a desktop window, in percent, as browsers offer them.
const zoomSteps = [80, 90, 100, 110, 125, 150, 175, 200];

/// What a zoom shortcut asks for.
enum ZoomChange { zoomIn, zoomOut, reset }

/// Pure: the zoom step after [change] from [percent].
int zoomAfter(ZoomChange change, int percent) => switch (change) {
  ZoomChange.zoomIn => zoomSteps.firstWhere(
    (s) => s > percent,
    orElse: () => zoomSteps.last,
  ),
  ZoomChange.zoomOut => zoomSteps.lastWhere(
    (s) => s < percent,
    orElse: () => zoomSteps.first,
  ),
  ZoomChange.reset => 100,
};

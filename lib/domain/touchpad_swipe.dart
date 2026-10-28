/// How far two fingers travel sideways for a full swipe, in logical pixels.
const swipeDistance = 160.0;

/// Where a two-finger swipe stands: its [forward] step (null for none) and
/// how near it is to completing, from 0 to 1.
typedef SwipeState = ({bool? forward, double ratio});

/// Pure: the history step a sideways swipe of [dx] asks for. Fingers moving
/// right go back, left forward, as in Firefox; it completes at [swipeDistance].
SwipeState swipeState(double dx) {
  if (dx == 0) return (forward: null, ratio: 0);
  return (forward: dx < 0, ratio: (dx.abs() / swipeDistance).clamp(0.0, 1.0));
}

/// Pure: the step a swipe that ended at [dx] goes through with, if any.
bool? swipeStep(double dx) {
  final state = swipeState(dx);
  return state.ratio >= 1 ? state.forward : null;
}

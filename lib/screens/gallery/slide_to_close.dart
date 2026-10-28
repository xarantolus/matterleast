/// Pure: whether sliding a gallery picture or video by [offset] (logical
/// pixels, down positive) and letting go at [velocity] (pixels per second)
/// closes the gallery. A tenth of the [height] is enough, and so is a quick
/// fling the way it was slid, however short; anything else springs back.
bool slideCloses({
  required double offset,
  required double velocity,
  required double height,
}) {
  if (offset == 0) return false;
  if (offset.abs() >= height / 10) return true;
  return velocity.sign == offset.sign && velocity.abs() >= slideFlingVelocity;
}

/// The speed of a let-go slide that closes the gallery, in logical pixels
/// per second.
const slideFlingVelocity = 700.0;

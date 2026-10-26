/// The size of message text, on top of the phone's font size.
enum MessageTextSize {
  small(0.9),
  normal(1),
  large(1.15),
  larger(1.3);

  const MessageTextSize(this.scale);

  final double scale;
}

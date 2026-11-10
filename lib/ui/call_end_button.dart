import 'package:material_ui/material_ui.dart';

/// Red in both themes; the scheme's own error colour turns pale in dark
/// mode, where a hang-up must still read as one.
const _endRed = Color(0xFFC62828);

/// The hang-up button of a call: a red circle with a white handset.
class CallEndButton extends StatelessWidget {
  const CallEndButton({
    required this.tooltip,
    required this.onPressed,
    this.size,
    this.dimension,
    super.key,
  });

  final String tooltip;
  final VoidCallback? onPressed;

  /// The icon's size; the button's default when null.
  final double? size;

  /// The button's width and height; the theme's when null.
  final double? dimension;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: tooltip,
    style: IconButton.styleFrom(
      backgroundColor: _endRed,
      foregroundColor: Colors.white,
      minimumSize: dimension == null ? null : Size.square(dimension!),
      fixedSize: dimension == null ? null : Size.square(dimension!),
    ),
    iconSize: size,
    icon: const Icon(Icons.call_end),
    onPressed: onPressed,
  );
}

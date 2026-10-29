import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/density.dart';

/// How message text is shown, as set on the Display page.
class MessageDisplay extends InheritedWidget {
  const MessageDisplay({
    required super.child,
    this.textScale = 1,
    this.wrapCode = false,
    super.key,
  });

  /// Message text size relative to the theme, before the phone's font size.
  final double textScale;

  /// Whether code blocks start wrapped instead of scrolling sideways.
  final bool wrapCode;

  static const _standard = MessageDisplay(child: SizedBox.shrink());

  static MessageDisplay of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MessageDisplay>() ?? _standard;

  @override
  bool updateShouldNotify(MessageDisplay old) =>
      textScale != old.textScale || wrapCode != old.wrapCode;
}

extension MessageTextScale on TextStyle {
  /// This style at the message text size of [context].
  TextStyle forMessages(BuildContext context, {double fallbackSize = 14}) {
    final scale = MessageDisplay.of(context).textScale;
    final height = context.density.lineHeight;
    if (scale == 1 && height == null) return this;
    return copyWith(
      fontSize: scale == 1 ? null : (fontSize ?? fallbackSize) * scale,
      height: height,
    );
  }
}

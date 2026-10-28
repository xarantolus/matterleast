import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';

final _modifiers = LogicalKeyboardKey.expandSynonyms({
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.shift,
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.meta,
});

/// On desktop, focus rings show after the keyboard moved the focus and not
/// after a mouse click, as the web's `:focus-visible` does. Flutter keeps
/// them after a click on desktop; this switches the highlight mode with the
/// last input that was used.
class KeyboardFocusRings extends StatelessWidget {
  const KeyboardFocusRings({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return child;
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.alwaysTouch;
        }
      },
      // Flutter notes the key before this runs, so its own choice of mode
      // is traditional once the strategy is automatic again.
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent && !_modifiers.contains(event.logicalKey)) {
            FocusManager.instance.highlightStrategy =
                FocusHighlightStrategy.automatic;
          }
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}

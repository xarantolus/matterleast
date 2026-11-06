import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';

/// Plays an animated picture while the desktop window has the focus and
/// shows it still otherwise, so a window in the background draws no frames.
/// Phones always play.
class PlayWhileFocused extends StatelessWidget {
  const PlayWhileFocused({
    required this.desktop,
    required this.child,
    super.key,
  });

  final bool desktop;
  final Widget child;

  @override
  Widget build(BuildContext context) => desktop
      ? ValueListenableBuilder(
          valueListenable: DesktopShell.focus,
          builder: (context, focused, child) =>
              TickerMode(enabled: focused, child: child!),
          child: child,
        )
      : child;
}

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';

/// While the desktop window doesn't have the focus (another window, another
/// workspace), nothing below it moves: animated pictures and emoji stop on
/// their frame and transitions jump to their end, so a window in the
/// background draws no frames. Phones always move.
class StillInBackground extends StatelessWidget {
  const StillInBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => isDesktop
      ? ValueListenableBuilder(
          valueListenable: DesktopShell.focus,
          builder: (context, focused, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations:
                  !focused || MediaQuery.disableAnimationsOf(context),
            ),
            child: child!,
          ),
          child: child,
        )
      : child;
}

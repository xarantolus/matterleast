import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/update_indicator.dart';
import 'package:window_manager/window_manager.dart';

/// The app bar of every page. On desktop it is also the window's title bar:
/// its empty space moves the window and a double click maximises or
/// restores it, and in the window's top right corner it ends with the
/// window buttons.
class WindowAppBar extends AppBar {
  WindowAppBar({
    super.key,
    super.leading,
    super.title,
    List<Widget>? actions,
    super.toolbarHeight,
    super.bottom,
  }) : super(
         flexibleSpace: isDesktop
             ? const DragToMoveArea(child: SizedBox.expand())
             : null,
         actions: isDesktop ? [...?actions, const WindowButtons()] : actions,
       );
}

/// Minimise, maximise or restore, and close (to the tray, like the
/// system's close), in the window's top right corner only.
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop || !WindowCorner.atTop(context)) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: DesktopShell.maximized,
      builder: (context, maximized, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WindowButton(
            tooltip: 'Minimise',
            icon: Icons.remove,
            onPressed: windowManager.minimize,
          ),
          if (maximized)
            _WindowButton(
              tooltip: 'Restore',
              icon: Icons.filter_none,
              iconSize: 16,
              onPressed: windowManager.unmaximize,
            )
          else
            _WindowButton(
              tooltip: 'Maximise',
              icon: Icons.crop_square,
              onPressed: windowManager.maximize,
            ),
          _WindowButton(
            tooltip: 'Close',
            icon: Icons.close,
            danger: true,
            onPressed: windowManager.close,
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconSize = 20,
    this.danger = false,
  });

  final String tooltip;
  final IconData icon;
  final double iconSize;
  final Future<void> Function() onPressed;

  /// Turns red under the pointer, as closing does on every desktop.
  final bool danger;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).colorScheme;
    final onBar = IconTheme.of(context).color ?? colours.onSurface;
    final danger = widget.danger && _hovered;
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        onTap: () => unawaited(widget.onPressed()),
        onHover: widget.danger
            ? (hovered) => setState(() => _hovered = hovered)
            : null,
        hoverColor: widget.danger
            ? colours.error
            : onBar.withValues(alpha: 0.08),
        highlightColor: widget.danger
            ? colours.error
            : onBar.withValues(alpha: 0.1),
        splashColor: Colors.transparent,
        child: SizedBox(
          // Windows' caption button width; the height is the bar's.
          width: 46,
          height: double.infinity,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: danger ? colours.onError : onBar,
          ),
        ),
      ),
    );
  }
}

/// Resize handles along the window's edges where the system draws none: on
/// Linux the window has no frame at all, and on Windows the hidden title
/// bar takes the top border with it. None while maximised.
class WindowEdges extends StatelessWidget {
  const WindowEdges({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final edges = switch (defaultTargetPlatform) {
      TargetPlatform.linux => null,
      TargetPlatform.windows => const [
        ResizeEdge.topLeft,
        ResizeEdge.top,
        ResizeEdge.topRight,
      ],
      _ => const <ResizeEdge>[],
    };
    if (edges != null && edges.isEmpty) return child;
    return ValueListenableBuilder(
      valueListenable: DesktopShell.maximized,
      // The same tree either way, so the app below keeps its state.
      builder: (context, maximized, child) => DragToResizeArea(
        resizeEdgeSize: 6,
        enableResizeEdges: maximized ? const [] : edges,
        child: child!,
      ),
      child: child,
    );
  }
}

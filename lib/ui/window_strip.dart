import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/update_indicator.dart';
import 'package:window_manager/window_manager.dart';

/// The strip's height at the system's normal text size, Discord's.
const windowStripHeight = 30.0;

/// Windows' red under the pointer on a close button; white reads on it.
const closeHoverColour = Color(0xFFC42B1C);

/// The strip's fill, a darker tone of the app bar so it reads as the
/// window's frame, and the colour of its text and icons on it.
({Color fill, Color text}) windowStripColours(ThemeData theme) {
  final bar = theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
  final onBar =
      theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
  final fill = Color.lerp(bar, Colors.black, 0.3)!;
  return (fill: fill, text: readableOn(fill, onBar));
}

/// On desktop, [child] under a thin strip across the window that is its
/// title bar, with resize handles along the edges. On a phone [child]
/// alone.
class WindowFrame extends StatelessWidget {
  const WindowFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return child;
    return WindowEdges(
      // The strip sits above the navigator, so its tooltips and the update
      // menu need an overlay of their own.
      child: Overlay.wrap(
        child: Column(
          children: [
            const WindowStrip(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// The app's name on space that moves the window (a double click maximises
/// or restores it), the update indicator, and the window buttons.
class WindowStrip extends StatelessWidget {
  const WindowStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = windowStripColours(Theme.of(context));
    const nameSize = 12.0;
    final height = math.max(
      windowStripHeight,
      MediaQuery.textScalerOf(context).scale(nameSize) + 16,
    );
    return Material(
      color: colours.fill,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'Matterleast',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w600,
                        color: colours.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const UpdateIndicator(),
            const _WindowButtons(),
          ],
        ),
      ),
    );
  }
}

/// Minimise, maximise or restore, and close (to the tray, like the
/// system's close).
class _WindowButtons extends StatelessWidget {
  const _WindowButtons();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: DesktopShell.maximized,
    builder: (context, maximized, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StripButton(
          tooltip: 'Minimise',
          icon: Icons.remove,
          onPressed: () => unawaited(windowManager.minimize()),
        ),
        if (maximized)
          StripButton(
            tooltip: 'Restore',
            icon: Icons.filter_none,
            iconSize: 12,
            onPressed: () => unawaited(windowManager.unmaximize()),
          )
        else
          StripButton(
            tooltip: 'Maximise',
            icon: Icons.crop_square,
            iconSize: 14,
            onPressed: () => unawaited(windowManager.maximize()),
          ),
        StripButton(
          tooltip: 'Close',
          icon: Icons.close,
          danger: true,
          onPressed: () => unawaited(windowManager.close()),
        ),
      ],
    ),
  );
}

/// A button in the window strip, the strip's height and Windows' caption
/// button width.
class StripButton extends StatefulWidget {
  const StripButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
    this.iconSize = 16,
    this.danger = false,
    super.key,
  }) : assert((icon == null) != (child == null), 'an icon or a child');

  final String tooltip;
  final IconData? icon;

  /// In place of [icon], drawn in the strip's icon colour.
  final Widget? child;
  final double iconSize;
  final VoidCallback onPressed;

  /// Turns red under the pointer, as closing does on every desktop.
  final bool danger;

  @override
  State<StripButton> createState() => _StripButtonState();
}

class _StripButtonState extends State<StripButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final onStrip = windowStripColours(Theme.of(context)).text;
    final red = widget.danger && _hovered;
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        mouseCursor: clickCursor,
        onTap: widget.onPressed,
        onHover: widget.danger
            ? (hovered) => setState(() => _hovered = hovered)
            : null,
        hoverColor: widget.danger
            ? closeHoverColour
            : onStrip.withValues(alpha: 0.1),
        highlightColor: widget.danger
            ? closeHoverColour
            : onStrip.withValues(alpha: 0.16),
        splashColor: Colors.transparent,
        child: SizedBox(
          width: 46,
          height: double.infinity,
          child: IconTheme.merge(
            data: IconThemeData(
              size: widget.iconSize,
              color: red ? Colors.white : onStrip,
            ),
            child: Center(child: widget.child ?? Icon(widget.icon)),
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

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/ui/tokens.dart';

/// Initials (or an [icon]) in a rounded square (a server) or a circle (a
/// person).
class InitialsBadge extends StatelessWidget {
  const InitialsBadge({
    required this.name,
    this.icon,
    this.size = 40,
    this.round = false,
    this.selected = false,
    this.faded = false,
    super.key,
  });

  final String name;
  final IconData? icon;
  final double size;
  final bool round;
  final bool selected;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final background = selected ? scheme.primary : tokens.accentWash;
    final foreground = selected ? scheme.onPrimary : tokens.accent;
    return Opacity(
      opacity: faded ? 0.5 : 1,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(round ? size / 2 : size / 4),
        ),
        child: icon != null
            ? Icon(icon, color: foreground, size: size * 0.55)
            : ExcludeSemantics(
                child: Text(
                  initialsOf(name),
                  // The badge has a fixed size, so its letters don't follow the
                  // system text size; the name is in the tooltip and semantics.
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: size * 0.38,
                  ),
                ),
              ),
      ),
    );
  }
}

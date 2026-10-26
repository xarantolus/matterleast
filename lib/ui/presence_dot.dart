import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A person's presence as a small ringed dot for the corner of an avatar.
/// Offline is a hollow ring, so it doesn't rely on a faint colour alone.
class PresenceDot extends StatelessWidget {
  const PresenceDot({
    required this.status,
    this.size = 10,
    this.announce = true,
    super.key,
  });

  /// `online`, `away`, `dnd` or anything else for offline.
  final String? status;
  final double size;

  /// Whether a screen reader reads the status; off where the words are
  /// shown next to the dot.
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fill = switch (status) {
      'online' => tokens.online,
      'away' => tokens.away,
      'dnd' => tokens.busy,
      _ => null,
    };
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill ?? tokens.page,
        border: fill == null
            ? Border.all(color: tokens.muted, width: size / 5)
            : Border.all(color: tokens.page, width: 1.5),
      ),
    );
    if (!announce) return ExcludeSemantics(child: dot);
    return Semantics(label: presenceLabel(status), child: dot);
  }
}

/// Words for a presence status.
String presenceLabel(String? status) => switch (status) {
  'online' => 'Online',
  'away' => 'Away',
  'dnd' => 'Do not disturb',
  _ => 'Offline',
};

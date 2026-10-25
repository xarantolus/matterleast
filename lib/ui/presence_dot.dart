import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A person's presence as a small ringed dot for the corner of an avatar.
class PresenceDot extends StatelessWidget {
  const PresenceDot({required this.status, this.size = 10, super.key});

  /// `online`, `away`, `dnd` or anything else for offline.
  final String? status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (status) {
          'online' => tokens.online,
          'away' => tokens.away,
          'dnd' => tokens.busy,
          _ => tokens.divider,
        },
        border: Border.all(color: tokens.page, width: 1.5),
      ),
    );
  }
}

/// Words for a presence status.
String presenceLabel(String? status) => switch (status) {
  'online' => 'Online',
  'away' => 'Away',
  'dnd' => 'Do not disturb',
  _ => 'Offline',
};

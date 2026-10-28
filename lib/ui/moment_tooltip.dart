import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/time_labels.dart';

/// On desktop, a mouse resting on [child] names [at] in full, in the app's
/// clock, after [prefix] (such as "Edited "). A phone has no hover, and a
/// long press there belongs to the message.
class MomentTooltip extends StatelessWidget {
  const MomentTooltip({
    required this.at,
    required this.child,
    this.prefix = '',
    super.key,
  });

  final DateTime at;
  final Widget child;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return child;
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return Tooltip(
      message: '$prefix${fullMomentLabel(at, use24: use24)}',
      child: child,
    );
  }
}

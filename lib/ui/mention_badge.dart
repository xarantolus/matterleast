import 'package:material_ui/material_ui.dart';

/// A count badge, marked when some of it is urgent, as upstream does.
class MentionBadge extends StatelessWidget {
  const MentionBadge({
    required this.count,
    this.urgent = false,
    this.backgroundColor,
    this.textColor,
    this.child,
    super.key,
  });

  final int count;
  final bool urgent;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!urgent) {
      return Badge.count(
        count: count,
        backgroundColor: backgroundColor,
        textColor: textColor,
        child: child,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Badge(
      backgroundColor: scheme.error,
      textColor: scheme.onError,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 11, color: scheme.onError),
          Text(count > 999 ? '999+' : '$count'),
        ],
      ),
      child: child,
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A centred icon, title and explanation, with an optional action, for
/// panes that have nothing (or nothing yet) to show.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.tokens.accent),
              const SizedBox(height: Spacing.lg),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.sm),
              Text(
                body,
                style: text.bodyMedium?.copyWith(color: context.tokens.muted),
                textAlign: TextAlign.center,
              ),
              if (action case final action?) ...[
                const SizedBox(height: Spacing.lg),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

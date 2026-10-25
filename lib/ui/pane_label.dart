import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A quiet small-caps line at the top of a pane, such as the server a
/// channel list belongs to, or that the data shown is saved data.
class PaneLabel extends StatelessWidget {
  const PaneLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.lg,
      Spacing.md,
      Spacing.lg,
      Spacing.xs,
    ),
    child: Text(
      text.toUpperCase(),
      style: context.tokens.smallCaps,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

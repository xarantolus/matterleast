import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// A scrolling single column, centred and at most 480 dp wide, for forms.
class NarrowPage extends StatelessWidget {
  const NarrowPage({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(Spacing.xl),
          children: children,
        ),
      ),
    ),
  );
}

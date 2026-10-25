import 'package:material_ui/material_ui.dart';

/// Fills the space and stays scrollable, so pull to refresh also works
/// over an empty state or a spinner.
class FillScrollable extends StatelessWidget {
  const FillScrollable({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(height: constraints.maxHeight, child: child),
    ),
  );
}

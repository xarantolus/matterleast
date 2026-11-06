import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';

/// Lets the mouse select the text of [child] on desktop, where programs
/// allow it; phones keep their taps.
class DesktopSelection extends StatelessWidget {
  const DesktopSelection({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      isDesktop ? SelectionArea(child: child) : child;
}

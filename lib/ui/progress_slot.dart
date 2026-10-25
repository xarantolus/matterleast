import 'package:material_ui/material_ui.dart';

/// The 3 dp slot under an app bar that holds the progress bar while
/// something runs. It is always there, so content never moves.
class ProgressSlot extends StatelessWidget implements PreferredSizeWidget {
  const ProgressSlot({required this.active, super.key});

  final bool active;

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 3,
    child: active
        ? const LinearProgressIndicator(minHeight: 3)
        : const SizedBox.shrink(),
  );
}

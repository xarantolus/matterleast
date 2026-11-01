import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/motion.dart';

/// A centred spinner that fades in after a beat, so a load that ends at once
/// shows none.
class DelayedSpinner extends StatelessWidget {
  const DelayedSpinner({super.key});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: motion(context, const Duration(milliseconds: 600)),
    curve: const Interval(0.5, 1),
    builder: (context, opacity, child) =>
        Opacity(opacity: opacity, child: child),
    child: const Center(child: CircularProgressIndicator()),
  );
}

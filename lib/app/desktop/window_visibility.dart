import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Stops the animations under it, such as a text caret's blink, while
/// [active] is false.
class TickersWhile extends StatelessWidget {
  const TickersWhile({super.key, required this.active, required this.child});

  final ValueListenable<bool> active;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: active,
    child: child,
    builder: (_, on, child) => TickerMode(enabled: on, child: child!),
  );
}

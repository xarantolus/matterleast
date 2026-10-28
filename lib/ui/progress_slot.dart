import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// The 3 dp slot under an app bar that holds the progress bar while
/// something runs. It is always there, so content never moves. With a
/// [delay], the bar shows only once the work has run that long, so work
/// that finishes quickly doesn't blink it.
class ProgressSlot extends StatefulWidget implements PreferredSizeWidget {
  const ProgressSlot({
    required this.active,
    this.delay = Duration.zero,
    super.key,
  });

  final bool active;
  final Duration delay;

  /// The wait before a refresh that started by itself, such as when the app
  /// comes back, shows.
  static const settleDelay = Duration(milliseconds: 400);

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  State<ProgressSlot> createState() => _ProgressSlotState();
}

class _ProgressSlotState extends State<ProgressSlot> {
  Timer? _wait;
  late var _shown = widget.active && widget.delay == Duration.zero;

  @override
  void initState() {
    super.initState();
    _follow();
  }

  @override
  void didUpdateWidget(ProgressSlot old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _follow();
  }

  void _follow() {
    _wait?.cancel();
    _wait = null;
    if (!widget.active) {
      _shown = false;
    } else if (widget.delay == Duration.zero) {
      _shown = true;
    } else if (!_shown) {
      _wait = Timer(widget.delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  void dispose() {
    _wait?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 3,
    child: _shown
        ? const LinearProgressIndicator(minHeight: 3)
        : const SizedBox.shrink(),
  );
}

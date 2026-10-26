import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

OverlayEntry? _shown;

/// A short line at the top of the screen that goes away by itself or on a
/// tap; it floats over the page, so nothing under it moves. A new one
/// replaces the one showing.
void showTopNotice(
  BuildContext context, {
  required String text,
  IconData? icon,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _shown?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _TopNotice(
      text: text,
      icon: icon,
      onGone: () {
        if (identical(_shown, entry)) _shown = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _shown = entry;
  overlay.insert(entry);
}

class _TopNotice extends StatefulWidget {
  const _TopNotice({
    required this.text,
    required this.icon,
    required this.onGone,
  });

  final String text;
  final IconData? icon;
  final VoidCallback onGone;

  @override
  State<_TopNotice> createState() => _TopNoticeState();
}

class _TopNoticeState extends State<_TopNotice>
    with SingleTickerProviderStateMixin {
  static const _shownFor = Duration(milliseconds: 2500);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
    _timer = Timer(_shownFor, _hide);
  }

  Future<void> _hide() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onGone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: scheme.onInverseSurface);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + Spacing.sm,
      left: Spacing.lg,
      right: Spacing.lg,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_curve),
        child: FadeTransition(
          opacity: _curve,
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: scheme.inverseSurface,
                elevation: 3,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _hide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm + 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon case final icon?) ...[
                          Icon(icon, size: 18, color: scheme.onInverseSurface),
                          const SizedBox(width: Spacing.sm),
                        ],
                        Flexible(child: Text(widget.text, style: style)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

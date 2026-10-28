import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/screens/root/open_panes.dart';

/// A mouse's back button goes back, as the back gesture does: what is on
/// top closes, a popout's page first. Its forward button opens again what
/// back closed. Only on desktop; a phone's mouse sends the system back.
class MouseNavigation extends ConsumerWidget {
  const MouseNavigation({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isDesktop) return child;
    return Listener(
      onPointerDown: (event) {
        if (event.kind != PointerDeviceKind.mouse) return;
        if (event.buttons & kBackMouseButton != 0) {
          final navigator = ref.read(conversationRoutesProvider).navigator;
          if (navigator != null) unawaited(navigator.maybePop());
        } else if (event.buttons & kForwardMouseButton != 0) {
          ref.read(forwardHistoryProvider).forward();
        }
      },
      child: child,
    );
  }
}

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/screens/root/open_history.dart';

/// A mouse's back button opens the conversation opened before the one
/// shown, its forward button the one after, as in a browser. Only on
/// desktop; a phone's mouse sends the system back.
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
          unawaited(stepHistory(ref.container, forward: false));
        } else if (event.buttons & kForwardMouseButton != 0) {
          unawaited(stepHistory(ref.container, forward: true));
        }
      },
      child: child,
    );
  }
}

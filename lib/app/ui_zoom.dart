import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/ui_zoom.dart';

/// Pure: [data] with fewer, larger logical pixels, so layouts reflow.
MediaQueryData zoomedMediaQuery(MediaQueryData data, double zoom) =>
    data.copyWith(
      size: data.size / zoom,
      devicePixelRatio: data.devicePixelRatio * zoom,
      padding: data.padding / zoom,
      viewPadding: data.viewPadding / zoom,
      viewInsets: data.viewInsets / zoom,
      systemGestureInsets: data.systemGestureInsets / zoom,
    );

/// The desktop window's zoom over [child]; phones keep their sizes.
class UiZoom extends ConsumerWidget {
  const UiZoom({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isDesktop) return child;
    final percent = ref.watch(uiZoomProvider).value ?? 100;
    final zoom = percent / 100;
    return Actions(
      actions: {
        ZoomIntent: CallbackAction<ZoomIntent>(
          onInvoke: (intent) => unawaited(
            ref
                .read(settingsStoreProvider)
                .write(Settings.uiZoom, zoomAfter(intent.change, percent)),
          ),
        ),
      },
      // One tree at every zoom, so nothing below is rebuilt.
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: constraints.biggest / zoom,
            child: MediaQuery(
              data: zoomedMediaQuery(MediaQuery.of(context), zoom),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

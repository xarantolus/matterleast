import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/update_providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// Marks whether [child] is the pane at the window's top right, whose app
/// bar carries the update indicator.
class WindowCorner extends InheritedWidget {
  const WindowCorner({super.key, this.here = true, required super.child});

  final bool here;

  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WindowCorner>()?.here ?? false;

  @override
  bool updateShouldNotify(WindowCorner old) => old.here != here;
}

/// An app bar action with a dot when a newer release is out, in the pane
/// at the window's top right only; nothing otherwise.
class UpdateIndicator extends ConsumerWidget {
  const UpdateIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!WindowCorner.contains(context)) return const SizedBox.shrink();
    final update = ref.watch(availableUpdateProvider);
    if (update == null) return const SizedBox.shrink();
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.open_in_new),
          onPressed: () => unawaited(
            launchUrl(
              Uri.parse(update.url),
              mode: LaunchMode.externalApplication,
            ),
          ),
          child: const Text('Open release page'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.visibility_off_outlined),
          onPressed: () => unawaited(
            ref
                .read(settingsStoreProvider)
                .write(Settings.dismissedRelease, update.tag),
          ),
          child: const Text('Hide until the next version'),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Matterleast ${versionLabel(update.tag)} is available',
        icon: const Badge(smallSize: 8, child: Icon(Icons.system_update_alt)),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

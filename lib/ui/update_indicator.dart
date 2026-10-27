import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/update_providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/app_update.dart';
import 'package:matterleast/ui/window_strip.dart';
import 'package:url_launcher/url_launcher.dart';

/// A button in the window strip with a dot when a newer release is out;
/// nothing otherwise.
class UpdateIndicator extends ConsumerWidget {
  const UpdateIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      builder: (context, controller, _) => StripButton(
        tooltip: 'Matterleast ${versionLabel(update.tag)} is available',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: const Badge(smallSize: 6, child: Icon(Icons.system_update_alt)),
      ),
    );
  }
}

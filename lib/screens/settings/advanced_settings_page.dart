import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/images/cache_usage.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/progress_slot.dart';

const _mediaBudgets = [100, 250, 500, 1000];
const _filesBudgets = [250, 500, 1000, 2000];

/// What the app keeps on the device, with ways to free it.
class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(cacheUsageProvider);
    final store = ref.read(settingsStoreProvider);
    final media = ref.watch(mediaCacheBudgetProvider).value;
    final files = ref.watch(filesCacheBudgetProvider).value;

    Future<void> pickBudget(
      String title,
      Setting<int> setting,
      int current,
      List<int> options,
    ) async {
      final picked = await pickOne(
        context,
        title: title,
        options: [
          for (final mb in options) mb * Settings.mebibyte,
          if (!options.contains(current ~/ Settings.mebibyte)) current,
        ],
        current: current,
        label: formatBytes,
      );
      if (picked != null) await store.write(setting, picked);
    }

    return ContentPage(
      title: const Text('Storage'),
      bottom: ProgressSlot(active: usage.isLoading),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          const SettingsHeader('Downloads on this device'),
          for (final kind in CacheKind.values)
            ListTile(
              title: Text(kind.label),
              subtitle: Text(switch (usage.value?[kind]) {
                null => usage.hasError ? "Couldn't measure" : 'Measuring…',
                0 => 'Empty',
                final bytes => formatBytes(bytes),
              }),
              trailing: TextButton(
                onPressed: (usage.value?[kind] ?? 0) == 0
                    ? null
                    : () => ref.read(cacheUsageProvider.notifier).clear(kind),
                child: const Text('Clear'),
              ),
            ),
          const SettingsHeader('Limits'),
          if (media != null)
            ListTile(
              title: const Text('Images in messages'),
              subtitle: Text('Up to ${formatBytes(media)}, oldest go first'),
              onTap: () => pickBudget(
                'Keep images up to',
                Settings.mediaCacheBytes,
                media,
                _mediaBudgets,
              ),
            ),
          if (files != null)
            ListTile(
              title: const Text('Opened files'),
              subtitle: Text('Up to ${formatBytes(files)}, oldest go first'),
              onTap: () => pickBudget(
                'Keep files up to',
                Settings.filesCacheBytes,
                files,
                _filesBudgets,
              ),
            ),
        ],
      ),
    );
  }
}

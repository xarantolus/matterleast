import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/data_saver.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/tokens.dart';

/// What loads by itself on mobile data and what waits for a tap.
class MobileDataSettingsPage extends ConsumerWidget {
  const MobileDataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(settingsStoreProvider);
    final images = ref.watch(imagesOnMobileDataProvider).value ?? true;
    final gifs = ref.watch(gifsOnMobileDataProvider).value ?? true;
    final linkPictures =
        ref.watch(linkPicturesOnMobileDataProvider).value ?? true;
    final dataSaver = ref.watch(dataSaverProvider).value ?? false;
    return ContentPage(
      title: const Text('Mobile data'),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          if (dataSaver)
            ListTile(
              leading: const Icon(Icons.data_saver_on_outlined),
              title: Text(
                dataSaverCoversWifi
                    ? '$dataSaverName is on: nothing below loads until you tap '
                          'it, whatever the switches say.'
                    : '$dataSaverName is on: on mobile data nothing below '
                          'loads until you tap it, whatever the switches say.',
                style: TextStyle(color: context.tokens.muted),
              ),
            ),
          SwitchListTile.adaptive(
            title: const Text('Load images'),
            subtitle: const Text('Otherwise tap an image to load it'),
            value: images,
            onChanged: (on) => store.write(Settings.imagesOnMobileData, on),
          ),
          SwitchListTile.adaptive(
            title: const Text('Play GIFs'),
            subtitle: const Text(
              'Otherwise a GIF stays still until you tap it',
            ),
            value: gifs,
            onChanged: (on) => store.write(Settings.gifsOnMobileData, on),
          ),
          SwitchListTile.adaptive(
            title: const Text('Show link preview pictures'),
            subtitle: const Text('Otherwise previews show only their text'),
            value: linkPictures,
            onChanged: (on) =>
                store.write(Settings.linkPicturesOnMobileData, on),
          ),
        ],
      ),
    );
  }
}

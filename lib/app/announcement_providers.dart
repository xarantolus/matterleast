import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'announcement_providers.g.dart';

@riverpod
Stream<Map<String, String>> dismissedAnnouncements(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.dismissedAnnouncements);

/// The server's announcement to show now, or null.
@riverpod
Announcement? announcementBanner(Ref ref, String url) => announcementToShow(
  ref.watch(featuresProvider(url).select((f) => f.value?.announcement)),
  ref.watch(dismissedAnnouncementsProvider).value?[url],
);

/// Hides [text] on [url] until the server's announcement changes.
Future<void> dismissAnnouncement(
  SettingsStore settings,
  String url,
  String text,
) async {
  final dismissed = await settings.read(Settings.dismissedAnnouncements);
  await settings.write(Settings.dismissedAnnouncements, {
    ...dismissed,
    url: text,
  });
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/announcement_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/ui/banner_strip.dart';

/// The server's announcement on the channel list: one line, the whole text
/// after a tap, a close button when the server allows dismissing it. Takes
/// no room when there is none.
class AnnouncementBanner extends ConsumerWidget {
  const AnnouncementBanner({
    required this.url,
    required this.teamId,
    super.key,
  });

  final String url;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(announcementBannerProvider(url));
    if (announcement == null) return const BannerSlot(child: null);
    final scheme = Theme.of(context).colorScheme;
    final colours = bannerColours(
      announcement.background,
      announcement.foreground,
      fallbackBg: scheme.secondaryContainer,
      fallbackFg: scheme.onSecondaryContainer,
    );
    void dismiss() => unawaited(
      dismissAnnouncement(
        ref.read(settingsStoreProvider),
        url,
        announcement.text,
      ),
    );
    return BannerSlot(
      child: BannerStrip(
        text: bannerLine(
          context,
          'announcement:${announcement.text.hashCode}:line',
          announcement.text,
        ),
        background: colours.background,
        foreground: colours.foreground,
        tooltip: 'Show announcement',
        onTap: () => showBannerSheet(
          context,
          title: 'Announcement',
          url: url,
          teamId: teamId,
          text: announcement.text,
          onDismiss: announcement.dismissible ? dismiss : null,
        ),
        onDismiss: announcement.dismissible ? dismiss : null,
      ),
    );
  }
}

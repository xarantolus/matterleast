import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/ui/banner_strip.dart';

/// A channel's banner under the app bar, when a licensed server has one
/// switched on: one line, the whole text after a tap. Takes no room when
/// there is none.
class ChannelBannerStrip extends ConsumerWidget {
  const ChannelBannerStrip({
    required this.url,
    required this.channelId,
    super.key,
  });

  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed =
        ref.watch(
          featuresProvider(url).select((f) => f.value?.channelBanners),
        ) ??
        false;
    final info = allowed
        ? ref.watch(channelInfoProvider(url, channelId)).value
        : null;
    final banner = info?.banner;
    if (info == null || banner == null) return const BannerSlot(child: null);
    final scheme = Theme.of(context).colorScheme;
    final colours = bannerColours(
      banner.colour,
      null,
      fallbackBg: scheme.secondaryContainer,
      fallbackFg: scheme.onSecondaryContainer,
    );
    return BannerSlot(
      child: BannerStrip(
        text: bannerLine(
          context,
          'banner:$channelId:${banner.text.hashCode}:line',
          banner.text,
        ),
        background: colours.background,
        foreground: colours.foreground,
        tooltip: 'Show the whole banner',
        onTap: () => showBannerSheet(
          context,
          title: 'Channel banner',
          url: url,
          teamId: info.teamId,
          text: banner.text,
        ),
      ),
    );
  }
}

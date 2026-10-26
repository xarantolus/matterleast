import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/ui/initials_badge.dart';

/// A team's icon from its server in a rounded square, with the team's
/// initials until it arrives, when it has none or when it can't be loaded.
class TeamIcon extends ConsumerWidget {
  const TeamIcon({
    required this.serverUrl,
    required this.teamId,
    required this.name,
    required this.iconUpdate,
    this.selected = false,
    this.size = 40,
    super.key,
  });

  final String serverUrl;
  final String teamId;
  final String name;

  /// The team's `last_team_icon_update`, which makes each icon's address
  /// unique, so a cached one never goes stale.
  final int? iconUpdate;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badge = InitialsBadge(name: name, size: size, selected: selected);
    final update = iconUpdate ?? 0;
    if (update <= 0) return badge;
    final caches = ref.watch(serverImageCachesProvider(serverUrl)).value;
    if (caches == null) return badge;
    final url = serverUri(Uri.parse(serverUrl), 'api/v4/teams/$teamId/image', {
      '_': '$update',
    });
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final radius = BorderRadius.circular(size / 4);
    return Container(
      width: size,
      height: size,
      foregroundDecoration: selected
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: radius,
        child: Image(
          image: ResizeImage(
            CachedNetworkImageProvider(
              url.toString(),
              cacheManager: caches.identity,
            ),
            width: pixels,
          ),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          frameBuilder: (context, child, frame, synchronous) =>
              frame == null && !synchronous ? badge : child,
          errorBuilder: (context, error, stack) => badge,
        ),
      ),
    );
  }
}

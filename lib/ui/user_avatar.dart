import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/ui/initials_badge.dart';

/// A person's round profile picture from their server, with their initials
/// in the same circle until it arrives or when it can't be loaded.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({
    required this.serverUrl,
    required this.userId,
    required this.name,
    this.lastPictureUpdate,
    this.size = 40,
    this.overrideIconUrl,
    super.key,
  });

  final String serverUrl;
  final String userId;

  /// Whose initials stand in for the picture.
  final String name;

  /// The user's `last_picture_update`, which makes each picture's address
  /// unique, so a cached one never goes stale.
  final int? lastPictureUpdate;
  final double size;

  /// A webhook's or bot's icon, absolute or relative to the server.
  final String? overrideIconUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badge = InitialsBadge(name: name, size: size, round: true);
    final caches = ref.watch(serverImageCachesProvider(serverUrl)).value;
    if (caches == null) return badge;
    final server = Uri.parse(serverUrl);
    final override = overrideIconUrl;
    final Uri url;
    if (override != null && override.isNotEmpty) {
      final proxy = ref.watch(imageProxyProvider(serverUrl)).value;
      if (proxy == null) return badge;
      final icon = imageRequestUri(override, server, proxy: proxy);
      if (icon == null) return badge;
      url = icon;
    } else {
      url = serverUri(server, 'api/v4/users/$userId/image', {
        '_': '${lastPictureUpdate ?? 0}',
      });
    }
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
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

/// A group message's picture: the first two others' pictures, overlapping
/// in a square of [size].
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    required this.serverUrl,
    required this.members,
    required this.fallback,
    this.size = 40,
    super.key,
  });

  final String serverUrl;
  final List<SwitchMember> members;

  /// Shown when no member is known.
  final Widget fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return fallback;
    if (members.length == 1) {
      final m = members.first;
      return UserAvatar(
        serverUrl: serverUrl,
        userId: m.userId,
        name: m.name,
        lastPictureUpdate: m.pictureUpdate,
        size: size,
      );
    }
    final small = size * 0.7;
    final ring = Theme.of(context).colorScheme.surface;
    Widget avatar(SwitchMember m) => UserAvatar(
      serverUrl: serverUrl,
      userId: m.userId,
      name: m.name,
      lastPictureUpdate: m.pictureUpdate,
      size: small,
    );
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          PositionedDirectional(top: 0, start: 0, child: avatar(members[0])),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 2),
              ),
              child: avatar(members[1]),
            ),
          ),
        ],
      ),
    );
  }
}

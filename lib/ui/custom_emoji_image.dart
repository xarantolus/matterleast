import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/image_rules.dart';

/// A server's custom emoji in a fixed square, so text around it never
/// moves when the image arrives. Shows [fallback] (usually the literal
/// `:name:`) when the image can't be loaded, such as a deleted emoji.
class CustomEmojiImage extends ConsumerWidget {
  const CustomEmojiImage({
    required this.serverUrl,
    required this.emojiId,
    required this.size,
    required this.fallback,
    super.key,
  });

  final String serverUrl;
  final String emojiId;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caches = ref.watch(serverImageCachesProvider(serverUrl)).value;
    if (caches == null) return SizedBox.square(dimension: size);
    final url = serverUri(Uri.parse(serverUrl), 'api/v4/emoji/$emojiId/image');
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    // Sized by the Image itself rather than a box, so the fallback text
    // can take the room it needs.
    return Image(
      image: ResizeImage(
        CachedNetworkImageProvider(
          url.toString(),
          cacheManager: caches.identity,
        ),
        width: pixels,
        height: pixels,
        policy: ResizeImagePolicy.fit,
      ),
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}

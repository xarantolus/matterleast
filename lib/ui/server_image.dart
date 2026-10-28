import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/tokens.dart';

/// An image in a message or link preview, in a box the caller sized
/// beforehand, so nothing moves when it arrives. Other hosts' images go
/// through the server's image proxy when it has one. On a metered
/// connection with "Load images on mobile data" off, the box waits for a
/// tap.
class ServerImage extends ConsumerStatefulWidget {
  const ServerImage({
    required this.serverUrl,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.placeholder,
    super.key,
  });

  final String serverUrl;

  /// Absolute, or relative to the server.
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final String? semanticLabel;

  /// Shown while the bytes load, instead of a tonal box.
  final Widget? placeholder;

  @override
  ConsumerState<ServerImage> createState() => _ServerImageState();
}

class _ServerImageState extends ConsumerState<ServerImage> {
  var _asked = false;

  @override
  Widget build(BuildContext context) {
    final caches = ref.watch(serverImageCachesProvider(widget.serverUrl)).value;
    final proxy = ref.watch(imageProxyProvider(widget.serverUrl)).value;
    final automatic = ref.watch(autoLoadImagesProvider);
    if (caches == null || proxy == null || automatic == null) {
      return _Box(width: widget.width, height: widget.height);
    }
    if (!automatic && !_asked) {
      return _Box(
        width: widget.width,
        height: widget.height,
        icon: Icons.image_outlined,
        label: 'Tap to load',
        onTap: () => setState(() => _asked = true),
      );
    }
    final url = imageRequestUri(
      widget.url,
      Uri.parse(widget.serverUrl),
      proxy: proxy,
    );
    if (url == null) return _unavailable;
    final pixels = (widget.width * MediaQuery.devicePixelRatioOf(context))
        .round();
    final placeholder =
        widget.placeholder ?? _Box(width: widget.width, height: widget.height);
    return Image(
      image: ResizeImage(
        CachedNetworkImageProvider(url.toString(), cacheManager: caches.media),
        width: pixels,
      ),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      semanticLabel: widget.semanticLabel,
      frameBuilder: (context, child, frame, synchronous) =>
          frame == null && !synchronous ? placeholder : child,
      errorBuilder: (context, error, stack) => _unavailable,
    );
  }

  Widget get _unavailable => _Box(
    width: widget.width,
    height: widget.height,
    icon: Icons.broken_image_outlined,
    label: 'Image not available',
  );
}

/// A neutral tonal box the size of the image.
class _Box extends StatelessWidget {
  const _Box({
    required this.width,
    required this.height,
    this.icon,
    this.label,
    this.onTap,
  });

  final double width;
  final double height;
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final label = this.label;
    final roomy = height >= 64 && width >= 96;
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: clickCursor,
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: icon == null
                ? null
                : FittedBox(
                    // Keeps the hint inside small boxes and at large text.
                    fit: BoxFit.scaleDown,
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: tokens.muted),
                          if (label != null && roomy)
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: tokens.muted),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

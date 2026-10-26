import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/gallery/video_player_view.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:video_player/video_player.dart';

/// The gallery over the page underneath, which shows through while the
/// picture is slid away.
Route<void> galleryRoute({
  required String url,
  required List<PostFile> files,
  required int initialIndex,
  required String heroPrefix,
  required String author,
  required DateTime sentAt,
}) => PageRouteBuilder<void>(
  opaque: false,
  transitionDuration: const Duration(milliseconds: 250),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  pageBuilder: (_, _, _) => GalleryScreen(
    url: url,
    files: files,
    initialIndex: initialIndex,
    heroPrefix: heroPrefix,
    author: author,
    sentAt: sentAt,
  ),
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

/// A message's pictures and videos on black, one per page: pinch or
/// double-tap to zoom, swipe between them, slide up or down to close. A tap
/// shows or hides the bars.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    required this.url,
    required this.files,
    required this.initialIndex,
    required this.heroPrefix,
    required this.author,
    required this.sentAt,
    super.key,
  });

  final String url;
  final List<PostFile> files;
  final int initialIndex;
  final String heroPrefix;
  final String author;
  final DateTime sentAt;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  late var _index = widget.initialIndex;
  late final _pages = ExtendedPageController(initialPage: widget.initialIndex);
  var _bars = true;

  /// Files whose original replaced the preview after zooming in.
  final _originals = <String>{};

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.files[_index];
    final caches = ref.watch(serverImageCachesProvider(widget.url)).value;
    final downloads = ref.watch(fileDownloadsProvider(widget.url)).value;
    final proxy = ref.watch(imageProxyProvider(widget.url)).value;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
        // A Scaffold, so snack bars about saving show above the pictures.
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ExtendedImageSlidePage(
            slideAxis: SlideAxis.vertical,
            slideType: SlideType.onlyImage,
            slidePageBackgroundHandler: (offset, size) =>
                Colors.black.withValues(
                  alpha: (1 - offset.dy.abs() / (size.height / 2)).clamp(0, 1),
                ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _bars = !_bars),
                  child: ExtendedImageGesturePageView.builder(
                    controller: _pages,
                    itemCount: widget.files.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final item = widget.files[i];
                      final heroTag = '${widget.heroPrefix}:${item.id}';
                      if (item.kind == FileKind.video) {
                        return Hero(
                          tag: heroTag,
                          child: _VideoPage(
                            url: widget.url,
                            file: item,
                            autoplay: i == widget.initialIndex,
                            onControlsChanged: (visible) {
                              if (i == _index) setState(() => _bars = visible);
                            },
                          ),
                        );
                      }
                      if (caches == null || downloads == null) {
                        return const SizedBox.expand();
                      }
                      final original =
                          item.kind == FileKind.gif ||
                          !item.hasPreview ||
                          _originals.contains(item.id);
                      final source = switch (item.link) {
                        final link? when proxy != null => imageRequestUri(
                          link,
                          Uri.parse(widget.url),
                          proxy: proxy,
                        ),
                        _? => null,
                        null =>
                          original
                              ? downloads.originalUri(item.id)
                              : downloads.previewUri(item.id),
                      };
                      if (source == null) return const SizedBox.expand();
                      return ExtendedImage(
                        image: CachedNetworkImageProvider(
                          source.toString(),
                          cacheManager: caches.media,
                        ),
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        enableSlideOutPage: true,
                        gaplessPlayback: true,
                        heroBuilderForSlidingPage: (child) => i == _index
                            ? Hero(tag: heroTag, child: child)
                            : child,
                        initGestureConfigHandler: (state) => GestureConfig(
                          maxScale: 5,
                          animationMaxScale: 6,
                          inPageView: true,
                          cacheGesture: true,
                          gestureDetailsIsChanged: (details) =>
                              _zoomed(item, details),
                        ),
                        onDoubleTap: (state) {
                          final scale = state.gestureDetails?.totalScale ?? 1;
                          state.handleDoubleTap(
                            scale: scale > 1.05 ? 1 : 2.5,
                            doubleTapPosition: state.pointerDownPosition,
                          );
                        },
                      );
                    },
                  ),
                ),
                _Bars(
                  visible: _bars,
                  title: widget.author,
                  subtitle: whenLabel(
                    widget.sentAt,
                    ref.watch(todayProvider),
                    use24: MediaQuery.alwaysUse24HourFormatOf(context),
                  ),
                  position: widget.files.length > 1
                      ? '${_index + 1} of ${widget.files.length}'
                      : null,
                  // An image from a message's text is no file to save.
                  menu: file.link == null
                      ? FileActionsMenu(
                          url: widget.url,
                          file: file,
                          color: Colors.white,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _zoomed(PostFile file, GestureDetails? details) {
    if (_originals.contains(file.id) || details?.totalScale == null) return;
    final width = MediaQuery.sizeOf(context).width;
    if (needsOriginal(
      file: file,
      scale: details!.totalScale!,
      shownWidth: width,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    )) {
      setState(() => _originals.add(file.id));
    }
  }
}

/// The author, time and menu on top, over a scrim only as dark as the white
/// text needs.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.visible,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.menu,
  });

  final bool visible;
  final String title;
  final String subtitle;
  final String? position;
  final Widget menu;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const scrim = Color(0x99000000);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            ColoredBox(
              color: scrim,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            [subtitle, ?position].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    menu,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A video streamed from the server with the session's header; it plays
/// only when opened from its tile, never when swiped to.
class _VideoPage extends ConsumerStatefulWidget {
  const _VideoPage({
    required this.url,
    required this.file,
    required this.autoplay,
    required this.onControlsChanged,
  });

  final String url;
  final PostFile file;
  final bool autoplay;
  final ValueChanged<bool> onControlsChanged;

  @override
  ConsumerState<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<_VideoPage> {
  VideoPlayerController? _video;
  var _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    if (_error != null) setState(() => _error = null);
    try {
      final session = await ref.read(serverSessionProvider(widget.url).future);
      final downloads = session.files;
      final cached = await downloads.cached(widget.file.id);
      final VideoPlayerController video;
      if (cached != null) {
        video = VideoPlayerController.file(cached);
      } else {
        final source = await session.api.streamSource(
          downloads.originalUri(widget.file.id),
        );
        video = VideoPlayerController.networkUrl(
          source.uri,
          httpHeaders: source.headers,
        );
      }
      if (!mounted) {
        await video.dispose();
        return;
      }
      _video = video;
      // A stalled connection must not leave a spinner forever.
      await video.initialize().timeout(const Duration(seconds: 30));
      if (!mounted) return;
      if (widget.autoplay) unawaited(video.play());
      setState(() => _ready = true);
    } on Object catch (e) {
      final video = _video;
      _video = null;
      await video?.dispose();
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    if (_error case final error?) {
      final cause = error is ApiError || error is TimeoutException
          ? requestProblemText(error, Uri.parse(widget.url).host)
          : 'Try again.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "The video didn't load. $cause You can also use Open with.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: Spacing.md),
              FilledButton(onPressed: _open, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (!_ready || video == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return VideoPlayerView(
      video: video,
      onControlsChanged: widget.onControlsChanged,
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/files/file_handoff.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/gallery/slide_to_close.dart';
import 'package:matterleast/screens/gallery/video_player_view.dart';
import 'package:matterleast/ui/motion.dart';
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
  var _fullScreen = false;

  /// Files whose original replaced the preview after zooming in.
  final _originals = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadAround(_index));
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// The picture of page [i], once the caches are open.
  ImageProvider? _imageOf(int i) {
    final caches = ref.read(serverImageCachesProvider(widget.url)).value;
    final downloads = ref.read(fileDownloadsProvider(widget.url)).value;
    final proxy = ref.read(imageProxyProvider(widget.url)).value;
    if (caches == null || downloads == null) return null;
    return _imageFor(widget.files[i], caches, downloads, proxy);
  }

  ImageProvider? _imageFor(
    PostFile item,
    ServerImageCaches caches,
    FileDownloads downloads,
    bool? proxy,
  ) {
    if (item.kind == FileKind.video) return null;
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
    if (source == null) return null;
    return CachedNetworkImageProvider(
      source.toString(),
      cacheManager: caches.media,
    );
  }

  /// Loads the pictures beside page [i], so a swipe rarely waits.
  void _preloadAround(int i) {
    if (!mounted) return;
    for (final next in [i - 1, i + 1]) {
      if (next < 0 || next >= widget.files.length) continue;
      if (_imageOf(next) case final image?) {
        unawaited(precacheImage(image, context, onError: (_, _) {}));
      }
    }
  }

  void _pageChanged(int i) {
    setState(() {
      _index = i;
      _fullScreen = false;
    });
    _preloadAround(i);
  }

  /// While a picture loads, its stand-in; when it failed, why, and Retry.
  Widget? _loadState(
    ExtendedImageState state,
    PostFile item,
  ) => switch (state.extendedImageLoadState) {
    LoadState.completed => null,
    // The picture it replaces stays until this one is there.
    LoadState.loading when state.extendedImageInfo != null => null,
    LoadState.loading => GalleryStandIn(
      url: widget.url,
      file: item,
      progress: state.loadingProgress,
    ),
    LoadState.failed => _Message(
      text:
          "The picture didn't load. "
          '${imageProblemText(state.lastException, Uri.parse(widget.url).host)}',
      action: 'Retry',
      onPressed: state.reLoadImage,
    ),
  };

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
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) => Navigator.of(context).maybePop(),
            ),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: ExtendedImageSlidePage(
                slideAxis: SlideAxis.vertical,
                slideType: SlideType.onlyImage,
                resetPageDuration: motion(
                  context,
                  const Duration(milliseconds: 250),
                ),
                slideEndHandler: slideEndCloses,
                slidePageBackgroundHandler: (offset, size) =>
                    Colors.black.withValues(
                      alpha: (1 - offset.dy.abs() / (size.height / 2)).clamp(
                        0,
                        1,
                      ),
                    ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _bars = !_bars),
                      child: ExtendedImageGesturePageView.builder(
                        controller: _pages,
                        itemCount: widget.files.length,
                        onPageChanged: _pageChanged,
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
                                onFullScreenChanged: (full) =>
                                    setState(() => _fullScreen = full),
                                onControlsChanged: (visible) {
                                  if (i == _index) {
                                    setState(() => _bars = visible);
                                  }
                                },
                              ),
                            );
                          }
                          final image = caches == null || downloads == null
                              ? null
                              : _imageFor(item, caches, downloads, proxy);
                          if (image == null) {
                            return GalleryStandIn(url: widget.url, file: item);
                          }
                          return ExtendedImage(
                            image: image,
                            fit: BoxFit.contain,
                            handleLoadingProgress: true,
                            loadStateChanged: (state) =>
                                _loadState(state, item),
                            semanticLabel: item.name,
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
                              gestureDetailsIsChanged: (details) =>
                                  _zoomed(item, details),
                            ),
                            onDoubleTap: (state) {
                              final scale =
                                  state.gestureDetails?.totalScale ?? 1;
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
                      visible: _bars && !_fullScreen,
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
        duration: motion(context, const Duration(milliseconds: 200)),
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
    required this.onFullScreenChanged,
  });

  final String url;
  final PostFile file;
  final bool autoplay;
  final ValueChanged<bool> onControlsChanged;
  final ValueChanged<bool> onFullScreenChanged;

  @override
  ConsumerState<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<_VideoPage> {
  VideoPlayerController? _video;
  var _ready = false;
  Object? _error;
  String? _notice;

  // video_player has no Linux implementation.
  bool get _system => defaultTargetPlatform == TargetPlatform.linux;

  @override
  void initState() {
    super.initState();
    _system ? _openExternally() : _open();
  }

  Future<void> _openExternally() async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final local = await ref
          .read(fileTransfersProvider(widget.url).notifier)
          .fetch(widget.file);
      if (local == null || !mounted) return;
      final handoff = (await ref.read(fileDownloadsProvider(widget.url).future))
          .handoffDirectory;
      final opened = await FileHandoff.open(local, widget.file, handoff);
      if (!mounted) return;
      setState(
        () => _notice = opened
            ? 'Opened ${widget.file.name} in your video player.'
            : 'No video player on this computer opens ${widget.file.name}. '
                  'Use Save as to keep it.',
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
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
    if (_notice case final notice?) {
      return _Message(
        text: notice,
        action: 'Open again',
        onPressed: _openExternally,
      );
    }
    if (_error case final error?) {
      final cause = error is ApiError || error is TimeoutException
          ? requestProblemText(error, Uri.parse(widget.url).host)
          : 'Try again.';
      return _Message(
        text: "The video didn't load. $cause You can also use Open with.",
        action: 'Retry',
        onPressed: _system ? _openExternally : _open,
      );
    }
    if (!_ready || video == null) {
      return GalleryStandIn(url: widget.url, file: widget.file);
    }
    return VideoPlayerView(
      video: video,
      onControlsChanged: widget.onControlsChanged,
      onFullScreenChanged: widget.onFullScreenChanged,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: Spacing.md),
            FilledButton(onPressed: onPressed, child: Text(action)),
          ],
        ),
      ),
    );
  }
}

/// Pure: [file]'s picture fitted whole into [page], or [page] if unknown.
Size galleryFit(PostFile file, Size page) {
  final width = file.width ?? 0;
  final height = file.height ?? 0;
  if (width <= 0 || height <= 0) return page;
  return applyBoxFit(
    BoxFit.contain,
    Size(width.toDouble(), height.toDouble()),
    page,
  ).destination;
}

/// Pure: why a picture didn't load, in the words for any failed request.
String imageProblemText(Object? error, String host) => switch (error) {
  ImageTooLargeException() =>
    'It is too large to show here. Use Save as to keep it.',
  HttpExceptionWithStatus(:final statusCode) => requestProblemText(
    ServerError(statusCode: statusCode),
    host,
  ),
  DioException() => requestProblemText(ApiError.from(error), host),
  null => requestProblemText(const UnexpectedFailure('none'), host),
  _ => requestProblemText(error, host),
};

/// A loading picture's stand-in at its final size, with progress over it.
class GalleryStandIn extends StatelessWidget {
  const GalleryStandIn({
    required this.url,
    required this.file,
    this.progress,
    super.key,
  });

  final String url;
  final PostFile file;
  final ImageChunkEvent? progress;

  @override
  Widget build(BuildContext context) {
    final total = progress?.expectedTotalBytes;
    final done = progress?.cumulativeBytesLoaded;
    final share = total == null || total <= 0 || done == null
        ? null
        : (done / total).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = galleryFit(file, constraints.biggest);
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.fromSize(
              size: size,
              child: MediaPicture(
                url: url,
                file: file,
                size: size,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox.square(
              dimension: 36,
              child: CircularProgressIndicator(
                value: share,
                strokeWidth: 3,
                color: Colors.white,
                backgroundColor: share == null ? null : Colors.white24,
              ),
            ),
          ],
        );
      },
    );
  }
}

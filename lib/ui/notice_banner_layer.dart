import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/notifications/notice_banner.dart';
import 'package:matterleast/notifications/notification_launch.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/incoming_call_banners.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/tokens.dart';

/// Keeps the banner above every route of the navigator below it, as an
/// overlay entry of that navigator.
class NoticeBannerOverlay extends StatefulWidget {
  const NoticeBannerOverlay({required this.child, super.key});

  final Widget child;

  @override
  State<NoticeBannerOverlay> createState() => _NoticeBannerOverlayState();
}

class _NoticeBannerOverlayState extends State<NoticeBannerOverlay> {
  final _entries = <OverlayEntry>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entries.addAll([
        OverlayEntry(builder: (_) => const _NoticeBannerLayer()),
        OverlayEntry(builder: (_) => const IncomingCallBanners()),
      ]);
      Overlay.of(context).insertAll(_entries);
    });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.remove();
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NoticeBannerLayer extends ConsumerWidget {
  const _NoticeBannerLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(noticeBannersProvider);
    if (notice == null) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final margin = isDesktop ? Spacing.md : Spacing.lg;
    final top = isDesktop
        ? kToolbarHeight + Spacing.sm
        : MediaQuery.paddingOf(context).top + Spacing.sm;
    return Positioned(
      top: top,
      right: margin,
      left: isDesktop ? null : margin,
      width: isDesktop
          ? math.min(math.max(320, size.width * 0.28), size.width - 2 * margin)
          : null,
      child: NoticeBanner(
        key: ValueKey(notice.id),
        notice: notice,
        onOpen: () {
          final navigator = ref.read(conversationRoutesProvider).navigator;
          ref.read(noticeBannersProvider.notifier).hide(notice.id);
          if (navigator == null) return;
          unawaited(
            openNotice(navigator, ref, notice.target, overCurrent: true),
          );
        },
      ),
    );
  }
}

/// The banner: a notice with a countdown, which a tap opens.
class NoticeBanner extends ConsumerStatefulWidget {
  const NoticeBanner({required this.notice, required this.onOpen, super.key});

  final BannerNotice notice;
  final VoidCallback onOpen;

  @override
  ConsumerState<NoticeBanner> createState() => _NoticeBannerState();
}

class _NoticeBannerState extends ConsumerState<NoticeBanner>
    with SingleTickerProviderStateMixin {
  static const _fade = Duration(milliseconds: 150);

  late final AnimationController _countdown;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    _countdown =
        AnimationController(
          vsync: this,
          duration: ref.read(noticeBannerDurationProvider),
          value: 1,
        )..addStatusListener((status) {
          if (status == AnimationStatus.dismissed) _leave();
        });
    unawaited(_countdown.reverse());
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  void _hide() =>
      ref.read(noticeBannersProvider.notifier).hide(widget.notice.id);

  void _leave() {
    if (_leaving) return;
    if (motion(context, _fade) == Duration.zero) {
      _hide();
    } else {
      setState(() => _leaving = true);
    }
  }

  void _pause() => _countdown.stop();

  void _resume() {
    if (!_leaving) unawaited(_countdown.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notice = widget.notice;
    Widget card = Semantics(
      liveRegion: true,
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: widget.onOpen,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Row(
                  children: [
                    _Picture(notice: notice),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            notice.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Dismiss',
                        onPressed: _hide,
                      ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _countdown,
              builder: (context, _) => LinearProgressIndicator(
                value: _countdown.value,
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
    if (isDesktop) {
      card = MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: card,
      );
    } else {
      card = GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -200) _hide();
        },
        child: Dismissible(
          key: ValueKey(notice.id),
          direction: DismissDirection.horizontal,
          resizeDuration: null,
          onDismissed: (_) => _hide(),
          child: card,
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _leaving ? 0 : 1),
      duration: motion(context, _fade),
      onEnd: () {
        if (_leaving) _hide();
      },
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: card,
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture({required this.notice});

  final BannerNotice notice;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final fallback = InitialsBadge(
      name: notice.title,
      size: _size,
      round: true,
    );
    final bytes = notice.avatar;
    if (bytes == null) return fallback;
    return ClipOval(
      child: Image.memory(
        bytes,
        width: _size,
        height: _size,
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/full_screen.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:video_player/video_player.dart';

const controlsHideDelay = Duration(seconds: 2);
const _scrim = Color(0x99000000);

/// "1:05" or "1:02:05".
String playbackTime(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final seconds = two(d.inSeconds % 60);
  if (d.inHours > 0) return '${d.inHours}:${two(d.inMinutes % 60)}:$seconds';
  return '${d.inMinutes}:$seconds';
}

/// An opened video with a small overlay: play and pause in the middle, a
/// scrubber at the bottom, hidden while playing until the next tap. Holding
/// plays at double speed; sliding the picture up or down closes the
/// gallery.
class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    required this.video,
    this.onControlsChanged,
    super.key,
  });

  /// An initialized controller, owned by the caller.
  final VideoPlayerController video;
  final ValueChanged<bool>? onControlsChanged;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  var _controls = true;
  var _fast = false;
  var _fullScreen = false;
  late var _playing = widget.video.value.isPlaying;
  var _playingBeforeHold = false;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    widget.video.addListener(_videoChanged);
    _setControls(true);
  }

  @override
  void didUpdateWidget(VideoPlayerView old) {
    super.didUpdateWidget(old);
    if (old.video != widget.video) {
      old.video.removeListener(_videoChanged);
      widget.video.addListener(_videoChanged);
      _videoChanged();
    }
  }

  @override
  void dispose() {
    widget.video.removeListener(_videoChanged);
    _hide?.cancel();
    if (_fullScreen) unawaited(leaveFullScreen());
    super.dispose();
  }

  // Called on every position tick; only a change of playing rebuilds.
  // Shown controls stay while stopped and hide again once playback goes
  // on, also after a stall that briefly stopped it.
  void _videoChanged() {
    final playing = widget.video.value.isPlaying;
    if (playing == _playing) return;
    setState(() => _playing = playing);
    if (!playing || _controls) _setControls(true);
  }

  /// Shows or hides the overlay; shown while playing, it hides again after
  /// [controlsHideDelay] unless touched.
  void _setControls(bool visible, {bool stay = false}) {
    _hide?.cancel();
    if (visible && _playing && !stay) {
      _hide = Timer(controlsHideDelay, () => _setControls(false));
    }
    if (visible == _controls) return;
    setState(() => _controls = visible);
    widget.onControlsChanged?.call(visible);
  }

  Future<void> _playPause() async {
    final video = widget.video;
    if (video.value.isPlaying) {
      await video.pause();
      return;
    }
    _setControls(false);
    if (video.value.isCompleted) await video.seekTo(Duration.zero);
    await video.play();
  }

  void _holdStart() {
    _playingBeforeHold = widget.video.value.isPlaying;
    setState(() => _fast = true);
    unawaited(widget.video.setPlaybackSpeed(2));
    if (!_playingBeforeHold) unawaited(widget.video.play());
  }

  void _holdEnd() {
    if (!_fast) return;
    setState(() => _fast = false);
    unawaited(widget.video.setPlaybackSpeed(1));
    if (!_playingBeforeHold) unawaited(widget.video.pause());
  }

  Future<void> _toggleFullScreen() async {
    _setControls(true);
    final enter = !_fullScreen;
    setState(() => _fullScreen = enter);
    if (enter) {
      await enterFullScreen(wide: widget.video.value.aspectRatio > 1);
    } else {
      await leaveFullScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final fade = motion(context, const Duration(milliseconds: 200));
    return PopScope(
      canPop: !_fullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_toggleFullScreen());
      },
      // For the buttons and slider, which look for one.
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImageSlidePageHandler(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setControls(!_controls),
                onLongPressStart: (_) => _holdStart(),
                onLongPressEnd: (_) => _holdEnd(),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: video.value.aspectRatio,
                    child: VideoPlayer(video),
                  ),
                ),
              ),
            ),
            if (_fast) const _SpeedBadge(),
            IgnorePointer(
              ignoring: !_controls,
              child: AnimatedOpacity(
                opacity: _controls ? 1 : 0,
                duration: fade,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: _PlayButton(
                        playing: _playing,
                        onPressed: _playPause,
                      ),
                    ),
                    // Positioned, so the slider gets its own height
                    // rather than the whole screen's.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomBar(
                        video: video,
                        fullScreen: _fullScreen,
                        onFullScreen: _toggleFullScreen,
                        onScrubStart: () => _setControls(true, stay: true),
                        onScrubEnd: () => _setControls(true),
                      ),
                    ),
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    iconSize: 40,
    style: IconButton.styleFrom(
      backgroundColor: _scrim,
      foregroundColor: Colors.white,
    ),
    tooltip: playing ? 'Pause' : 'Play',
    onPressed: onPressed,
    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
  );
}

class _SpeedBadge extends StatelessWidget {
  const _SpeedBadge();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      // Below the gallery's top bar.
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            color: _scrim,
            shape: StadiumBorder(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '2x',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: Colors.white),
                ),
                const Icon(Icons.fast_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.video,
    required this.fullScreen,
    required this.onFullScreen,
    required this.onScrubStart,
    required this.onScrubEnd,
  });

  final VideoPlayerController video;
  final bool fullScreen;
  final VoidCallback onFullScreen;
  final VoidCallback onScrubStart;
  final VoidCallback onScrubEnd;

  // The scrim also takes every touch on the bar, so a drag that starts
  // here never slides the gallery away.
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _scrim,
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: _Scrubber(
              video: video,
              onStart: onScrubStart,
              onEnd: onScrubEnd,
            ),
          ),
          IconButton(
            color: Colors.white,
            tooltip: fullScreen ? 'Exit full screen' : 'Full screen',
            onPressed: onFullScreen,
            icon: Icon(fullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
        ],
      ),
    ),
  );
}

class _Scrubber extends StatefulWidget {
  const _Scrubber({
    required this.video,
    required this.onStart,
    required this.onEnd,
  });

  final VideoPlayerController video;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  State<_Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<_Scrubber> {
  /// Where the finger is while dragging, so the thumb doesn't jump back to
  /// the last reported position.
  double? _dragging;

  void _seek(double ms) =>
      unawaited(widget.video.seekTo(Duration(milliseconds: ms.round())));

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Colors.white);
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.video,
      builder: (context, value, _) {
        final total = value.duration.inMilliseconds;
        final at =
            _dragging ?? min(value.position.inMilliseconds, total).toDouble();
        return Row(
          children: [
            Text(
              '${playbackTime(Duration(milliseconds: at.round()))}'
              ' / ${playbackTime(value.duration)}',
              style: style,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white24,
                  trackShape: const RoundedRectSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: at,
                  max: max(total, 1).toDouble(),
                  onChangeStart: (v) {
                    widget.onStart();
                    setState(() => _dragging = v);
                  },
                  onChanged: (v) {
                    setState(() => _dragging = v);
                    _seek(v);
                  },
                  onChangeEnd: (v) {
                    _seek(v);
                    setState(() => _dragging = null);
                    widget.onEnd();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

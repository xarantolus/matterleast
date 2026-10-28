import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/gallery/settled_end_player.dart';
import 'package:matterleast/screens/gallery/slide_to_close.dart';
import 'package:matterleast/screens/gallery/video_player_view.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _FakePlayer extends VideoPlayerPlatform {
  final calls = <String>[];
  final speeds = <double>[];
  final seeks = <Duration>[];
  final _events = <int, StreamController<VideoEvent>>{};
  var _next = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _next++;
    _events[id] = StreamController<VideoEvent>(
      onListen: () => _events[id]!.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(minutes: 1, seconds: 30),
          size: const Size(1920, 1080),
        ),
      ),
    );
    return id;
  }

  /// Plays again on a seek after the end, as Windows' player does.
  var replaysAfterEnd = false;
  var _ended = false;
  var completions = 0;

  /// The player reaching the end of the video.
  void finish() {
    _ended = true;
    completions++;
    for (final events in _events.values) {
      events.add(VideoEvent(eventType: VideoEventType.completed));
    }
  }

  /// The player reporting that it stopped or went on by itself.
  void playing(bool value) {
    for (final events in _events.values) {
      events.add(
        VideoEvent(
          eventType: VideoEventType.isPlayingStateUpdate,
          isPlaying: value,
        ),
      );
    }
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async => _events.remove(playerId);

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> play(int playerId) async => calls.add('play');

  @override
  Future<void> pause(int playerId) async => calls.add('pause');

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async =>
      speeds.add(speed);

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    seeks.add(position);
    if (replaysAfterEnd && _ended) {
      _ended = false;
      playing(true);
      Timer(const Duration(milliseconds: 250), finish);
    }
  }

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.blueGrey);
}

void main() {
  late _FakePlayer platform;
  late VideoPlayerController video;

  setUp(() {
    platform = _FakePlayer();
    VideoPlayerPlatform.instance = platform;
  });

  Future<void> open(WidgetTester tester, {bool play = false}) async {
    video = VideoPlayerController.networkUrl(Uri.parse('https://x.test/v'));
    await video.initialize();
    if (play) await video.play();
    // The view in a slide-to-close gallery page over a home page.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  PageRouteBuilder<void>(
                    opaque: false,
                    transitionDuration: Duration.zero,
                    pageBuilder: (_, _, _) => ExtendedImageSlidePage(
                      slideAxis: SlideAxis.vertical,
                      slideEndHandler: slideEndCloses,
                      child: VideoPlayerView(video: video),
                    ),
                  ),
                ),
                child: const Text('Home'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Home'));
    // Not pumpAndSettle: a playing video ticks its position for ever.
    await tester.pump();
    await tester.pump();
    platform.calls.clear();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Awaiting it directly never returns: its futures run on the test's
    // fake clock.
    unawaited(video.dispose());
    await tester.pump();
  }

  bool controlsShown(WidgetTester tester) => !tester
      .widget<IgnorePointer>(
        find
            .ancestor(
              of: find.byType(Slider),
              matching: find.byType(IgnorePointer),
            )
            .first,
      )
      .ignoring;

  Finder viewOf() => find.byType(VideoPlayerView);

  // Away from the play button in the middle.
  Offset onVideo(WidgetTester tester) =>
      tester.getCenter(viewOf()) + const Offset(0, -150);

  testWidgets('controls hide two seconds after the last touch', (tester) async {
    await open(tester, play: true);
    expect(controlsShown(tester), isTrue);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(controlsShown(tester), isTrue);
    await tester.pump(const Duration(milliseconds: 600));
    expect(controlsShown(tester), isFalse);

    await close(tester);
  });

  testWidgets('a paused video keeps its controls', (tester) async {
    await open(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(controlsShown(tester), isTrue);
    await close(tester);
  });

  testWidgets('controls come back when playback stops', (tester) async {
    await open(tester, play: true);
    await tester.pump(controlsHideDelay);
    expect(controlsShown(tester), isFalse);

    await video.pause();
    await tester.pump();
    expect(controlsShown(tester), isTrue);
    await close(tester);
  });

  testWidgets('controls hide again after a stall', (tester) async {
    await open(tester, play: true);
    platform.playing(false);
    await tester.pump();
    platform.playing(true);
    await tester.pump(controlsHideDelay);
    await tester.pump();

    expect(controlsShown(tester), isFalse);
    await close(tester);
  });

  testWidgets('pressing play hides the controls at once', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();

    expect(platform.calls, ['play']);
    expect(controlsShown(tester), isFalse);
    await close(tester);
  });

  testWidgets('a tap shows and hides the controls', (tester) async {
    await open(tester, play: true);
    await tester.pump(controlsHideDelay);
    expect(controlsShown(tester), isFalse);

    await tester.tapAt(onVideo(tester));
    await tester.pump(kDoubleTapTimeout);
    expect(controlsShown(tester), isTrue);

    await tester.tapAt(onVideo(tester));
    await tester.pump(kDoubleTapTimeout);
    expect(controlsShown(tester), isFalse);
    await close(tester);
  });

  testWidgets('a tap on a phone shows the controls and leaves playback alone', (
    tester,
  ) async {
    await open(tester, play: true);
    await tester.pump(controlsHideDelay);
    await tester.tapAt(onVideo(tester));
    await tester.pump(kDoubleTapTimeout);
    expect(controlsShown(tester), isTrue);
    expect(video.value.isPlaying, isTrue);
    expect(platform.calls, isNot(contains('pause')));
    await close(tester);
  });

  testWidgets('a click on desktop plays and pauses', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await open(tester, play: true);
    await tester.pump(controlsHideDelay);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: onVideo(tester));
    addTearDown(mouse.removePointer);

    await mouse.down(onVideo(tester));
    await mouse.up();
    await tester.pump(kDoubleTapTimeout);
    expect(platform.calls, ['pause']);

    await mouse.down(onVideo(tester));
    await mouse.up();
    await tester.pump(kDoubleTapTimeout);
    expect(platform.calls, ['pause', 'play']);
    debugDefaultTargetPlatformOverride = null;
    await close(tester);
  });

  testWidgets('holding plays at double speed until released', (tester) async {
    await open(tester, play: true);
    final hold = await tester.startGesture(onVideo(tester));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

    expect(platform.speeds.last, 2);
    expect(find.text('2x'), findsOneWidget);

    await hold.up();
    await tester.pump();
    expect(platform.speeds.last, 1);
    expect(find.text('2x'), findsNothing);
    await close(tester);
  });

  testWidgets('sliding the video down closes the gallery', (tester) async {
    await open(tester);
    await tester.timedDragFrom(
      onVideo(tester),
      const Offset(0, 400),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayerView), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    await close(tester);
  });

  testWidgets('a short quick slide from the play button closes the gallery', (
    tester,
  ) async {
    await open(tester);
    expect(controlsShown(tester), isTrue);
    await tester.timedDragFrom(
      tester.getCenter(find.byIcon(Icons.play_arrow)),
      const Offset(0, 60),
      const Duration(milliseconds: 50),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayerView), findsNothing);
    await close(tester);
  });

  testWidgets('a short slow slide springs back', (tester) async {
    await open(tester);
    await tester.timedDragFrom(
      onVideo(tester),
      const Offset(0, 40),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VideoPlayerView), findsOneWidget);
    await close(tester);
  });

  testWidgets('dragging on the scrubber seeks and never closes', (
    tester,
  ) async {
    await open(tester);
    final slider = find.byType(Slider);

    await tester.timedDrag(
      slider,
      const Offset(0, -400),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(find.byType(VideoPlayerView), findsOneWidget);

    await tester.drag(slider, const Offset(150, 0));
    await tester.pumpAndSettle();
    expect(find.byType(VideoPlayerView), findsOneWidget);
    expect(platform.seeks, isNotEmpty);
    expect(platform.seeks.last, greaterThan(Duration.zero));
    await close(tester);
  });

  testWidgets('a mouse moving over a playing video brings its controls '
      'back until it rests', (tester) async {
    await open(tester, play: true);
    await tester.pump(controlsHideDelay);
    expect(controlsShown(tester), isFalse);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: onVideo(tester));
    addTearDown(mouse.removePointer);
    await mouse.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(controlsShown(tester), isTrue);

    await tester.pump(controlsHideDelay);
    expect(controlsShown(tester), isFalse);
    await close(tester);
  });

  testWidgets('the pointer hides with the controls of a playing video and '
      'comes back when it moves', (tester) async {
    await open(tester, play: true);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: onVideo(tester));
    addTearDown(mouse.removePointer);
    await mouse.moveBy(const Offset(20, 0));
    await tester.pump();
    MouseCursor? cursor() =>
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1);
    expect(cursor(), isNot(SystemMouseCursors.none));

    await tester.pump(controlsHideDelay);
    await tester.pump();
    expect(controlsShown(tester), isFalse);
    expect(cursor(), SystemMouseCursors.none);

    await mouse.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(cursor(), isNot(SystemMouseCursors.none));
    await close(tester);
  });

  testWidgets('a paused video keeps the pointer', (tester) async {
    await open(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: onVideo(tester));
    addTearDown(mouse.removePointer);
    await tester.pump(const Duration(seconds: 5));
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      isNot(SystemMouseCursors.none),
    );
    await close(tester);
  });

  for (final settled in [false, true]) {
    testWidgets(
      'a finished video ${settled ? 'stays still' : 'replays its '
                'end for ever without the guard'}',
      (tester) async {
        platform.replaysAfterEnd = true;
        if (settled) VideoPlayerPlatform.instance = SettledEndPlayer(platform);
        await open(tester, play: true);
        platform.finish();
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        if (settled) {
          expect(platform.completions, 1);
          expect(video.value.isPlaying, isFalse);
          expect(video.value.position, video.value.duration);
        } else {
          // What Windows did: seek to the end, play, finish, seek again.
          expect(platform.completions, greaterThan(2));
          platform.replaysAfterEnd = false;
          await tester.pump(const Duration(milliseconds: 300));
        }
        await close(tester);
      },
    );
  }

  test('only a seek to the end of a finished video is left out', () {
    const length = Duration(minutes: 1);
    expect(seeksPastEnd(ended: true, to: length, duration: length), isTrue);
    expect(
      seeksPastEnd(ended: true, to: Duration.zero, duration: length),
      isFalse,
    );
    expect(seeksPastEnd(ended: false, to: length, duration: length), isFalse);
  });

  test('playback times', () {
    expect(playbackTime(Duration.zero), '0:00');
    expect(playbackTime(const Duration(minutes: 1, seconds: 5)), '1:05');
    expect(
      playbackTime(const Duration(hours: 1, minutes: 2, seconds: 5)),
      '1:02:05',
    );
  });
}

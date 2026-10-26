import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
  Future<void> seekTo(int playerId, Duration position) async =>
      seeks.add(position);

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

  test('playback times', () {
    expect(playbackTime(Duration.zero), '0:00');
    expect(playbackTime(const Duration(minutes: 1, seconds: 5)), '1:05');
    expect(
      playbackTime(const Duration(hours: 1, minutes: 2, seconds: 5)),
      '1:02:05',
    );
  });
}

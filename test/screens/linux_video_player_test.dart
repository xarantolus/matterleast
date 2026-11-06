import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/gallery/linux_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _Mpv extends VideoPlayerPlatform {
  _Mpv(this.events);

  final Stream<VideoEvent> events;

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events;
}

void main() {
  test('a decoder error that mpv works around does not stop the video', () {
    final events = StreamController<VideoEvent>();
    addTearDown(events.close);
    final seen = <VideoEventType>[];
    final errors = <Object>[];
    ForgivingPlayer(_Mpv(events.stream))
        .videoEventsFor(1)
        .listen((event) => seen.add(event.eventType), onError: errors.add);

    events
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 8),
        ),
      )
      ..addError(PlatformException(code: '', message: 'Could not open codec.'))
      ..add(VideoEvent(eventType: VideoEventType.isPlayingStateUpdate));

    return Future<void>.delayed(Duration.zero).then((_) {
      expect(errors, isEmpty);
      expect(seen, [
        VideoEventType.initialized,
        VideoEventType.isPlayingStateUpdate,
      ]);
    });
  });
}

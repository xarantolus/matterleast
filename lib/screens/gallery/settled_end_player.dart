import 'package:flutter/foundation.dart';
import 'package:matterleast/screens/gallery/forwarding_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Puts [SettledEndPlayer] in front of the Windows player.
void settleVideoEnds() {
  if (defaultTargetPlatform != TargetPlatform.windows) return;
  VideoPlayerPlatform.instance = SettledEndPlayer(VideoPlayerPlatform.instance);
}

/// Pure: whether a seek to [to] only replays the end of an [ended] video.
bool seeksPastEnd({
  required bool ended,
  required Duration to,
  required Duration? duration,
}) => ended && duration != null && to >= duration;

/// video_player seeks a finished video to its end, and the Windows player
/// plays again on any seek after the end, so the end loops; drops that seek.
class SettledEndPlayer extends ForwardingVideoPlayer {
  SettledEndPlayer(super.player);

  final _ended = <int>{};
  final _durations = <int, Duration>{};

  @override
  Future<void> dispose(int playerId) {
    _ended.remove(playerId);
    _durations.remove(playerId);
    return super.dispose(playerId);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      super.videoEventsFor(playerId).map((event) {
        switch (event.eventType) {
          case VideoEventType.initialized:
            if (event.duration case final duration?) {
              _durations[playerId] = duration;
            }
          case VideoEventType.completed:
            _ended.add(playerId);
          default:
        }
        return event;
      });

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    if (seeksPastEnd(
      ended: _ended.contains(playerId),
      to: position,
      duration: _durations[playerId],
    )) {
      return;
    }
    _ended.remove(playerId);
    await super.seekTo(playerId, position);
  }

  @override
  Future<void> play(int playerId) {
    _ended.remove(playerId);
    return super.play(playerId);
  }
}

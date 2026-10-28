import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Puts [SettledEndPlayer] in front of the platform's player where it
/// replays on a seek after the end.
void settleVideoEnds() {
  if (defaultTargetPlatform != TargetPlatform.windows) return;
  VideoPlayerPlatform.instance = SettledEndPlayer(VideoPlayerPlatform.instance);
}

/// Pure: whether a seek to [to] would only replay the end of a video that
/// has [ended], [duration] long.
bool seeksPastEnd({
  required bool ended,
  required Duration to,
  required Duration? duration,
}) => ended && duration != null && to >= duration;

/// The platform's video player with one seek left out. video_player answers
/// a finished video by seeking to its end, so the last frame shows; the
/// Windows player starts playing again on any seek after the end, so that
/// seek replays the last moment, finishes again and is answered again, and
/// the picture flickers between frames for ever. Everything else is passed
/// on as it is.
class SettledEndPlayer extends VideoPlayerPlatform {
  SettledEndPlayer(this._player);

  final VideoPlayerPlatform _player;
  final _ended = <int>{};
  final _durations = <int, Duration>{};

  @override
  Future<void> init() => _player.init();

  @override
  Future<void> dispose(int playerId) {
    _ended.remove(playerId);
    _durations.remove(playerId);
    return _player.dispose(playerId);
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) =>
      _player.createWithOptions(options);

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      _player.videoEventsFor(playerId).map((event) {
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
    await _player.seekTo(playerId, position);
  }

  @override
  Future<void> play(int playerId) {
    _ended.remove(playerId);
    return _player.play(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) =>
      _player.setLooping(playerId, looping);

  @override
  Future<void> pause(int playerId) => _player.pause(playerId);

  @override
  Future<void> setVolume(int playerId, double volume) =>
      _player.setVolume(playerId, volume);

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) =>
      _player.setPlaybackSpeed(playerId, speed);

  @override
  Future<Duration> getPosition(int playerId) => _player.getPosition(playerId);

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      _player.buildViewWithOptions(options);

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) =>
      _player.setMixWithOthers(mixWithOthers);

  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) =>
      _player.setAllowBackgroundPlayback(allowBackgroundPlayback);

  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool preventsDisplaySleepDuringVideoPlayback,
  ) => _player.setPreventsDisplaySleepDuringVideoPlayback(
    playerId,
    preventsDisplaySleepDuringVideoPlayback,
  );

  @override
  Future<void> setWebOptions(int playerId, VideoPlayerWebOptions options) =>
      _player.setWebOptions(playerId, options);

  @override
  Future<List<VideoAudioTrack>> getAudioTracks(int playerId) =>
      _player.getAudioTracks(playerId);

  @override
  Future<void> selectAudioTrack(int playerId, String trackId) =>
      _player.selectAudioTrack(playerId, trackId);

  @override
  bool isAudioTrackSupportAvailable() => _player.isAudioTrackSupportAvailable();

  @override
  Future<List<VideoTrack>> getVideoTracks(int playerId) =>
      _player.getVideoTracks(playerId);

  @override
  Future<void> selectVideoTrack(int playerId, VideoTrack? track) =>
      _player.selectVideoTrack(playerId, track);

  @override
  bool isVideoTrackSupportAvailable() => _player.isVideoTrackSupportAvailable();
}

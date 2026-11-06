import 'package:material_ui/material_ui.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A video player that hands every call to [player]; subclasses change the
/// few they need to.
abstract class ForwardingVideoPlayer extends VideoPlayerPlatform {
  ForwardingVideoPlayer(this.player);

  final VideoPlayerPlatform player;

  @override
  Future<void> init() => player.init();

  @override
  Future<void> dispose(int playerId) => player.dispose(playerId);

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) =>
      player.createWithOptions(options);

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      player.videoEventsFor(playerId);

  @override
  Future<void> seekTo(int playerId, Duration position) =>
      player.seekTo(playerId, position);

  @override
  Future<void> play(int playerId) => player.play(playerId);

  @override
  Future<void> setLooping(int playerId, bool looping) =>
      player.setLooping(playerId, looping);

  @override
  Future<void> pause(int playerId) => player.pause(playerId);

  @override
  Future<void> setVolume(int playerId, double volume) =>
      player.setVolume(playerId, volume);

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) =>
      player.setPlaybackSpeed(playerId, speed);

  @override
  Future<Duration> getPosition(int playerId) => player.getPosition(playerId);

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      player.buildViewWithOptions(options);

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) =>
      player.setMixWithOthers(mixWithOthers);

  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) =>
      player.setAllowBackgroundPlayback(allowBackgroundPlayback);

  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool preventsDisplaySleepDuringVideoPlayback,
  ) => player.setPreventsDisplaySleepDuringVideoPlayback(
    playerId,
    preventsDisplaySleepDuringVideoPlayback,
  );

  @override
  Future<void> setWebOptions(int playerId, VideoPlayerWebOptions options) =>
      player.setWebOptions(playerId, options);

  @override
  Future<List<VideoAudioTrack>> getAudioTracks(int playerId) =>
      player.getAudioTracks(playerId);

  @override
  Future<void> selectAudioTrack(int playerId, String trackId) =>
      player.selectAudioTrack(playerId, trackId);

  @override
  bool isAudioTrackSupportAvailable() => player.isAudioTrackSupportAvailable();

  @override
  Future<List<VideoTrack>> getVideoTracks(int playerId) =>
      player.getVideoTracks(playerId);

  @override
  Future<void> selectVideoTrack(int playerId, VideoTrack? track) =>
      player.selectVideoTrack(playerId, track);

  @override
  bool isVideoTrackSupportAvailable() => player.isVideoTrackSupportAvailable();
}

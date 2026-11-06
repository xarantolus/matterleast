import 'package:flutter/foundation.dart';
import 'package:matterleast/screens/gallery/forwarding_video_player.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Plays video on Linux with libmpv; the other platforms keep their own
/// players.
void useMpvOnLinux() {
  if (defaultTargetPlatform != TargetPlatform.linux) return;
  VideoPlayerMediaKit.ensureInitialized(linux: true);
  VideoPlayerPlatform.instance = ForgivingPlayer(VideoPlayerPlatform.instance);
}

/// The media_kit bridge turns every decoder error mpv logs into a failure
/// that empties the controller (duration zero), also the "could not open
/// codec" of a hardware decoder it then replaces with software decoding. A
/// video that really can't play never reports its size, which the gallery's
/// own timeout turns into an error, so the errors are dropped.
class ForgivingPlayer extends ForwardingVideoPlayer {
  ForgivingPlayer(super.player);

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      super.videoEventsFor(playerId).handleError((Object _) {});
}

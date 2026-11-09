import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_connection.freezed.dart';

/// Where the user's call connection is.
enum CallPhase {
  idle,

  /// Asking for the microphone, fetching TURN credentials, opening the
  /// socket.
  preparing,

  /// `join` sent, waiting for the server to accept.
  joining,

  /// The offer is out and ICE is running.
  connecting,
  connected,

  /// The calls socket dropped and is coming back; the audio may go on.
  reconnecting,

  /// The audio path is being rebuilt on a new network path.
  restartingIce,
  ended,
  failed,
}

/// Why a call is over without the user leaving it.
enum CallEnd { left, hostEnded, removed, sessionLost, signedOut }

enum CallFailureKind {
  /// The server said no, in its own words.
  server,

  /// The calls socket didn't connect or went away for good.
  noConnection,

  /// The media path never came up.
  media,

  /// Something that took too long.
  timeout,
}

class CallFailure {
  const CallFailure(this.kind, this.message);
  final CallFailureKind kind;

  /// What to show: the server's words when it said something.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is CallFailure && other.kind == kind && other.message == message;

  @override
  int get hashCode => Object.hash(kind, message);
}

enum AudioRoute { earpiece, speaker, bluetooth, wired }

/// The state of the user's own call connection, for the screens to render.
/// Who else is in the call and what they do lives in the calls state.
@freezed
abstract class CallConnection with _$CallConnection {
  const factory CallConnection({
    @Default(CallPhase.idle) CallPhase phase,

    /// The call this is about: its server and channel; empty while idle.
    @Default('') String url,
    @Default('') String channelId,

    /// The user's session in the call; empty until the server accepted.
    @Default('') String sessionId,
    @Default(true) bool muted,

    /// The microphone is not available: the user hears but isn't heard.
    @Default(false) bool listenOnly,
    AudioRoute? route,
    @Default(<AudioRoute>[]) List<AudioRoute> routes,
    CallFailure? failure,
    CallEnd? endedBy,
  }) = _CallConnection;

  const CallConnection._();

  /// In a call, or becoming part of one.
  bool get active => switch (phase) {
    CallPhase.idle || CallPhase.ended || CallPhase.failed => false,
    _ => true,
  };
}

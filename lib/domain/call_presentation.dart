import 'package:matterleast/domain/call_connection.dart';

/// One line about the user's connection to a call; empty when there is
/// nothing to say (idle, or the user left).
String callConnectionText(CallConnection state) => switch (state.phase) {
  CallPhase.idle => '',
  CallPhase.preparing ||
  CallPhase.joining ||
  CallPhase.connecting => 'Connecting…',
  CallPhase.connected =>
    state.listenOnly
        ? 'In the call, listening only: no microphone access'
        : (state.muted ? 'In the call · muted' : 'In the call'),
  CallPhase.reconnecting => 'Reconnecting…',
  CallPhase.restartingIce => 'Restoring the audio connection…',
  CallPhase.ended => switch (state.endedBy) {
    CallEnd.ended => 'The call ended',
    CallEnd.removed => 'You were removed from the call',
    CallEnd.sessionLost => 'You were dropped from the call',
    CallEnd.signedOut => 'You were signed out',
    CallEnd.left || null => '',
  },
  CallPhase.failed => state.failure?.message ?? "The call couldn't continue",
};

String audioRouteLabel(AudioRoute route) => switch (route) {
  AudioRoute.earpiece => 'Phone',
  AudioRoute.speaker => 'Speaker',
  AudioRoute.bluetooth => 'Bluetooth',
  AudioRoute.wired => 'Headset',
};

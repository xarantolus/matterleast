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
    CallEnd.ended => 'Call ended',
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

/// How long a call has run. The one place that compares the server's start
/// time with the phone's clock: it only feeds a ticking display, and never
/// shows less than zero when the phone's clock is behind.
Duration callElapsed(DateTime? startAt, DateTime now) {
  if (startAt == null) return Duration.zero;
  final elapsed = now.difference(startAt);
  return elapsed.isNegative ? Duration.zero : elapsed;
}

/// "4:07", or "1:02:03" from an hour on.
String callTimerLabel(Duration elapsed) {
  final total = elapsed.inSeconds;
  String two(int n) => n.toString().padLeft(2, '0');
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}

/// The microphones or speakers as people name them: the system's
/// "default: " prefix dropped and two entries with one name shown once.
List<AudioDevice> friendlyDevices(List<AudioDevice> devices) {
  final seen = <String>{};
  return [
    for (final d in devices)
      if (seen.add(_deviceName(d.label)))
        (id: d.id, label: _deviceName(d.label)),
  ];
}

String _deviceName(String label) {
  final name = label.replaceFirst(RegExp(r'^default\s*[:-]\s*'), '').trim();
  return name.isEmpty ? label : name;
}

/// The line under a call's title: "3 in the call · 1 hand raised".
String callSubtitle({required int people, int hands = 0}) => [
  people == 1 ? '1 in the call' : '$people in the call',
  if (hands > 0) hands == 1 ? '1 hand raised' : '$hands hands raised',
].join(' · ');

import 'package:matterleast/domain/call_connection.dart';

/// Every wait and limit of a call connection. The server closes the media
/// session 10 s after the calls socket drops and 10 s after `join` without
/// an offer, so the budgets sit inside those.
class CallTimings {
  const CallTimings({
    this.reconnectBudget = const Duration(seconds: 8),
    this.reconnectBackoff = const Duration(milliseconds: 500),
    this.answerTimeout = const Duration(seconds: 3),
    this.connectTimeout = const Duration(seconds: 15),
    this.joinTimeout = const Duration(seconds: 8),
    this.lockWait = const Duration(seconds: 5),
    this.lockRetry = const Duration(milliseconds: 50),
    this.pingInterval = const Duration(seconds: 1),
    this.turnTimeout = const Duration(seconds: 3),
    this.restartGap = const Duration(seconds: 2),
    this.restartWait = const Duration(seconds: 6),
    this.missedPongs = 3,
    this.maxRestarts = 3,
  });

  /// How long after a drop the calls socket may take to be back.
  final Duration reconnectBudget;
  final Duration reconnectBackoff;

  /// How long an offer of ours may go unanswered before it counts as lost.
  final Duration answerTimeout;

  /// How long the first connection may take.
  final Duration connectTimeout;

  /// How long `join` may go unanswered.
  final Duration joinTimeout;
  final Duration lockWait;
  final Duration lockRetry;
  final Duration pingInterval;
  final Duration turnTimeout;

  /// The least time between two ICE restarts.
  final Duration restartGap;

  /// How long a restart has to bring the path back before the next one.
  final Duration restartWait;

  /// Pings in a row without an answer that mean the path is gone.
  final int missedPongs;

  /// ICE restarts in a row, without the path coming back, before giving up.
  final int maxRestarts;
}

sealed class ReconnectStep {
  const ReconnectStep();
}

final class ReconnectIn extends ReconnectStep {
  const ReconnectIn(this.delay);
  final Duration delay;
}

final class ReconnectGiveUp extends ReconnectStep {
  const ReconnectGiveUp();
}

/// What to do [sinceDrop] after the calls socket dropped: try again after
/// the backoff, or give up when that would land past the budget.
ReconnectStep reconnectStep(
  Duration sinceDrop, {
  CallTimings timings = const CallTimings(),
}) => sinceDrop + timings.reconnectBackoff >= timings.reconnectBudget
    ? const ReconnectGiveUp()
    : ReconnectIn(timings.reconnectBackoff);

/// A server `error` after our `reconnect` means the session is gone.
CallFailure reconnectRefusal(String serverText) =>
    CallFailure(CallFailureKind.server, switch (serverText) {
      'no call ongoing' => 'The call ended while the connection was down.',
      'session not found in call state' =>
        'The connection was down too long and the call dropped you.',
      final text when text.isNotEmpty => text,
      _ => 'The call could not be resumed.',
    });

enum IceTrigger { peerDisconnected, peerFailed, networkChanged, missedPongs }

enum IceRestartStep { restart, wait, giveUp }

/// Whether to restart ICE now. Only one restart runs at a time, two are
/// [CallTimings.restartGap] apart, and after [CallTimings.maxRestarts]
/// that didn't bring the path back the call ends. A failed peer restarts
/// regardless of the gap: waiting longer only costs the call.
IceRestartStep iceRestartStep({
  required IceTrigger trigger,
  required bool restarting,
  required int attempts,
  required Duration? sinceLast,
  CallTimings timings = const CallTimings(),
}) {
  if (restarting) return IceRestartStep.wait;
  if (attempts >= timings.maxRestarts) return IceRestartStep.giveUp;
  final soon = sinceLast != null && sinceLast < timings.restartGap;
  if (soon && trigger != IceTrigger.peerFailed) return IceRestartStep.wait;
  return IceRestartStep.restart;
}

/// Whether [missed] pings in a row went unanswered.
bool pongsLost(int missed, {CallTimings timings = const CallTimings()}) =>
    missed >= timings.missedPongs;

/// A server's media port as its ICE candidates name it.
typedef MediaPort = ({String protocol, int port});

/// The port the server's candidates (SDP candidate lines) agree on most,
/// for the message when ICE never connects; null without a usable line.
MediaPort? mediaPortOf(Iterable<String> candidateLines) {
  final counts = <MediaPort, int>{};
  for (final line in candidateLines) {
    final parts = line.trim().replaceFirst('candidate:', '').split(' ');
    if (parts.length < 6) continue;
    final protocol = parts[2].toLowerCase();
    final port = int.tryParse(parts[5]);
    if (port == null || (protocol != 'udp' && protocol != 'tcp')) continue;
    final key = (protocol: protocol, port: port);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return (counts.entries.toList()..sort((a, b) => b.value - a.value)).first.key;
}

/// What to say when the media path never came up.
CallFailure mediaFailure(MediaPort? port) => CallFailure(
  CallFailureKind.media,
  port == null
      ? "Couldn't set up the audio connection to the call server."
      : "Couldn't reach the call server's media port "
            '(${port.protocol.toUpperCase()} ${port.port}). '
            'A firewall may block it.',
);

/// The route to use: the user's pick while that device is there, else a
/// headset, else the earpiece for a direct message and the speaker for
/// anything larger.
AudioRoute? chooseRoute({
  required List<AudioRoute> available,
  required AudioRoute? pinned,
  required bool direct,
}) {
  if (available.isEmpty) return null;
  if (pinned != null && available.contains(pinned)) return pinned;
  for (final headset in const [AudioRoute.bluetooth, AudioRoute.wired]) {
    if (available.contains(headset)) return headset;
  }
  final preferred = direct ? AudioRoute.earpiece : AudioRoute.speaker;
  if (available.contains(preferred)) return preferred;
  return available.first;
}

/// Whether a pinned route stays pinned: it is dropped once its device is
/// gone.
AudioRoute? keepPin(AudioRoute? pinned, List<AudioRoute> available) =>
    pinned != null && available.contains(pinned) ? pinned : null;

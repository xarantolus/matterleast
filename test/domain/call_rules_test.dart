import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_rules.dart';

void main() {
  group('reconnecting the calls socket', () {
    test('tries again while the budget allows another try', () {
      final step = reconnectStep(const Duration(seconds: 2));
      expect(step, isA<ReconnectIn>());
      expect((step as ReconnectIn).delay, const Duration(milliseconds: 500));
    });

    test('gives up when another try would land past the budget', () {
      expect(
        reconnectStep(const Duration(milliseconds: 7500)),
        isA<ReconnectGiveUp>(),
      );
      expect(
        reconnectStep(const Duration(milliseconds: 7499)),
        isA<ReconnectIn>(),
      );
    });

    test('follows injected durations', () {
      const timings = CallTimings(reconnectBudget: Duration(seconds: 2));
      expect(
        reconnectStep(const Duration(seconds: 2), timings: timings),
        isA<ReconnectGiveUp>(),
      );
    });

    test('says what the server said, in plain words', () {
      expect(
        reconnectRefusal('no call ongoing').message,
        contains('ended while'),
      );
      expect(
        reconnectRefusal('session not found in call state').message,
        contains('dropped you'),
      );
      expect(reconnectRefusal('forbidden').message, 'forbidden');
      expect(reconnectRefusal('').message, isNotEmpty);
    });
  });

  group('restarting ICE', () {
    IceRestartStep step({
      IceTrigger trigger = IceTrigger.peerDisconnected,
      bool restarting = false,
      int attempts = 0,
      Duration? sinceLast,
    }) => iceRestartStep(
      trigger: trigger,
      restarting: restarting,
      attempts: attempts,
      sinceLast: sinceLast,
    );

    test('starts when nothing runs', () {
      expect(step(), IceRestartStep.restart);
      expect(step(trigger: IceTrigger.networkChanged), IceRestartStep.restart);
      expect(step(trigger: IceTrigger.missedPongs), IceRestartStep.restart);
    });

    test('never starts a second one while one runs', () {
      expect(step(restarting: true), IceRestartStep.wait);
      expect(
        step(restarting: true, trigger: IceTrigger.peerFailed),
        IceRestartStep.wait,
      );
    });

    test('keeps the minimum gap, except for a failed peer', () {
      const soon = Duration(milliseconds: 500);
      expect(step(sinceLast: soon), IceRestartStep.wait);
      expect(
        step(sinceLast: soon, trigger: IceTrigger.peerFailed),
        IceRestartStep.restart,
      );
      expect(
        step(sinceLast: const Duration(seconds: 2)),
        IceRestartStep.restart,
      );
    });

    test('gives up after the allowed restarts', () {
      expect(step(attempts: 2), IceRestartStep.restart);
      expect(step(attempts: 3), IceRestartStep.giveUp);
    });
  });

  test('three missed pongs mean the path is lost', () {
    expect(pongsLost(2), isFalse);
    expect(pongsLost(3), isTrue);
  });

  group('the media port', () {
    test('is the one most server candidates name', () {
      final port = mediaPortOf([
        'candidate:1 1 udp 2130706431 10.0.2.2 8445 typ host',
        'candidate:2 1 UDP 2130706431 127.0.0.1 8445 typ host',
        'candidate:3 1 tcp 1671430143 10.0.2.2 8445 typ host tcptype passive',
      ]);
      expect(port, (protocol: 'udp', port: 8445));
    });

    test('is null without a usable candidate', () {
      expect(mediaPortOf(['', 'candidate:1 1 udp']), isNull);
      expect(mediaPortOf(const []), isNull);
    });

    test('is named in the failure text', () {
      expect(
        mediaFailure((protocol: 'udp', port: 8445)).message,
        contains('UDP 8445'),
      );
      expect(mediaFailure(null).kind, CallFailureKind.media);
    });
  });

  group('the audio route', () {
    const all = [AudioRoute.earpiece, AudioRoute.speaker, AudioRoute.bluetooth];

    test('is the earpiece in a direct message and the speaker elsewhere', () {
      const phone = [AudioRoute.earpiece, AudioRoute.speaker];
      expect(
        chooseRoute(available: phone, pinned: null, direct: true),
        AudioRoute.earpiece,
      );
      expect(
        chooseRoute(available: phone, pinned: null, direct: false),
        AudioRoute.speaker,
      );
    });

    test('prefers a headset', () {
      expect(
        chooseRoute(available: all, pinned: null, direct: true),
        AudioRoute.bluetooth,
      );
    });

    test('keeps the user pick until that device goes', () {
      expect(
        chooseRoute(available: all, pinned: AudioRoute.speaker, direct: true),
        AudioRoute.speaker,
      );
      const gone = [AudioRoute.earpiece, AudioRoute.speaker];
      expect(
        chooseRoute(
          available: gone,
          pinned: AudioRoute.bluetooth,
          direct: true,
        ),
        AudioRoute.earpiece,
      );
      expect(keepPin(AudioRoute.bluetooth, gone), isNull);
      expect(keepPin(AudioRoute.speaker, gone), AudioRoute.speaker);
    });

    test('is none without a device', () {
      expect(chooseRoute(available: [], pinned: null, direct: true), isNull);
    });
  });

  group('choosing an audio device', () {
    const a = (id: 'default: Built-in', label: 'Built-in');
    const b = (id: 'usb', label: 'USB headset');

    test('takes the pick while it is there', () {
      expect(chooseDevice(available: [a, b], pinned: 'usb'), b);
    });

    test('falls back to the system default, then the first', () {
      expect(chooseDevice(available: [b, a], pinned: 'gone'), a);
      expect(chooseDevice(available: [b], pinned: null), b);
      expect(chooseDevice(available: [], pinned: 'usb'), isNull);
    });

    test('drops a pin once its device is gone', () {
      expect(keepDevicePin('usb', [a, b]), 'usb');
      expect(keepDevicePin('usb', [a]), isNull);
    });
  });
}

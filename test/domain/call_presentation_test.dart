import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_presentation.dart';

void main() {
  String text(CallConnection c) => callConnectionText(c);

  test('says nothing before a call and after the user leaves', () {
    expect(text(const CallConnection()), '');
    expect(
      text(const CallConnection(phase: CallPhase.ended, endedBy: CallEnd.left)),
      '',
    );
  });

  test('says where the connection is', () {
    for (final phase in [
      CallPhase.preparing,
      CallPhase.joining,
      CallPhase.connecting,
    ]) {
      expect(text(CallConnection(phase: phase)), 'Connecting…');
    }
    expect(
      text(const CallConnection(phase: CallPhase.reconnecting)),
      'Reconnecting…',
    );
    expect(
      text(const CallConnection(phase: CallPhase.restartingIce)),
      contains('Restoring'),
    );
  });

  test('says who is heard while connected', () {
    expect(
      text(const CallConnection(phase: CallPhase.connected)),
      'In the call · muted',
    );
    expect(
      text(const CallConnection(phase: CallPhase.connected, muted: false)),
      'In the call',
    );
    expect(
      text(const CallConnection(phase: CallPhase.connected, listenOnly: true)),
      contains('listening only'),
    );
  });

  test('says why a call ended or failed', () {
    expect(
      text(
        const CallConnection(phase: CallPhase.ended, endedBy: CallEnd.removed),
      ),
      contains('removed'),
    );
    expect(
      text(
        const CallConnection(
          phase: CallPhase.failed,
          failure: CallFailure(CallFailureKind.server, 'forbidden'),
        ),
      ),
      'forbidden',
    );
  });

  group('the call timer', () {
    final start = DateTime.utc(2030, 1, 1, 12);

    test('counts from the server start time', () {
      expect(
        callElapsed(start, start.add(const Duration(minutes: 4, seconds: 7))),
        const Duration(minutes: 4, seconds: 7),
      );
    });

    test('never shows less than zero when the phone clock is behind', () {
      expect(
        callElapsed(start, start.subtract(const Duration(minutes: 3))),
        Duration.zero,
      );
    });

    test('is zero while the start time is not known', () {
      expect(callElapsed(null, start), Duration.zero);
    });

    test('reads as minutes and seconds, with hours from the first hour', () {
      expect(callTimerLabel(Duration.zero), '0:00');
      expect(callTimerLabel(const Duration(minutes: 4, seconds: 7)), '4:07');
      expect(
        callTimerLabel(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });
  });

  group('device names', () {
    test('drop the system prefix and list one name once', () {
      expect(
        friendlyDevices(const [
          (id: 'default', label: 'default: Built-in audio'),
          (id: 'hw', label: 'Built-in audio'),
          (id: 'usb', label: 'USB headset'),
        ]),
        [
          (id: 'default', label: 'Built-in audio'),
          (id: 'usb', label: 'USB headset'),
        ],
      );
    });

    test('keep a name that is only the prefix', () {
      expect(
        friendlyDevices(const [(id: 'd', label: 'default')]).single.label,
        'default',
      );
    });
  });

  test('the call subtitle counts people and raised hands', () {
    expect(callSubtitle(people: 1), '1 in the call');
    expect(callSubtitle(people: 3, hands: 1), '3 in the call · 1 hand raised');
    expect(callSubtitle(people: 3, hands: 2), '3 in the call · 2 hands raised');
  });
}

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
}

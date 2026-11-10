import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/domain/call_ui_rules.dart';

CallsConfig _config({bool? host, bool? ringing}) => CallsConfig.fromJson({
  'HostControlsAllowed': ?host,
  'EnableRinging': ?ringing,
});

void main() {
  group('host controls', () {
    bool open({
      bool? allowed = true,
      String? host = 'me',
      String? self = 'me',
      bool admin = false,
    }) => hostControlsOpen(
      config: allowed == null ? null : _config(host: allowed),
      hostId: host,
      selfId: self,
      admin: admin,
    );

    test('the host may use them where the server allows', () {
      expect(open(), isTrue);
    });
    test('a system admin may too', () {
      expect(open(host: 'ann', admin: true), isTrue);
    });
    test('another participant may not', () {
      expect(open(host: 'ann'), isFalse);
    });
    test('nobody may where the server does not allow them', () {
      expect(open(allowed: false, admin: true), isFalse);
      expect(open(allowed: null), isFalse);
    });
    test('before the user is known nobody is the host', () {
      expect(open(host: '', self: null), isFalse);
    });
  });

  group('ringing', () {
    bool rings({
      bool? on = true,
      String? type = 'D',
      String? owner = 'ann',
      String? self = 'me',
    }) => callRings(
      config: _config(ringing: on),
      channelType: type,
      ownerId: owner,
      selfId: self,
    );

    test('a direct or group call started by someone else rings', () {
      expect(rings(), isTrue);
      expect(rings(type: 'G'), isTrue);
    });
    test('a call the user started does not', () {
      expect(rings(owner: 'me'), isFalse);
    });
    test('a channel call does not', () {
      expect(rings(type: 'O'), isFalse);
      expect(rings(type: 'P'), isFalse);
    });
    test('nothing rings where the server turned ringing off', () {
      expect(rings(on: false), isFalse);
      expect(rings(on: null), isFalse);
    });
  });

  test('the same sessions in the same order are equal', () {
    expect(const SessionIds(['a', 'b']), const SessionIds(['a', 'b']));
    expect(const SessionIds(['a', 'b']), isNot(const SessionIds(['b', 'a'])));
  });

  group('where a call shows', () {
    test('a desktop window with panes docks it in the channel list', () {
      expect(callSurface(desktop: true, panes: true), CallSurface.dock);
    });

    test('a narrow desktop window and every phone show the bar', () {
      expect(callSurface(desktop: true, panes: false), CallSurface.bar);
      expect(callSurface(desktop: false, panes: true), CallSurface.bar);
      expect(callSurface(desktop: false, panes: false), CallSurface.bar);
    });
  });
}

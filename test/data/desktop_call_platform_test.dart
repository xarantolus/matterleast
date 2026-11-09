import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/domain/call_connection.dart';

void main() {
  const mic = (id: 'mic', label: 'Microphone');
  const pad = (id: 'pad', label: 'Headset');
  const every = Duration(seconds: 3);

  test('tells the call when the devices change, and only then', () {
    fakeAsync((async) {
      var now = (inputs: <AudioDevice>[mic], outputs: <AudioDevice>[]);
      var listed = 0;
      final platform = DesktopCallPlatform(
        lister: () async {
          listed++;
          return now;
        },
        pollEvery: every,
      );
      var changes = 0;
      final sub = platform.routesChanged.listen((_) => changes++);
      async.elapse(every);
      expect(changes, 1);
      async.elapse(every * 3);
      expect(changes, 1);
      now = (inputs: [mic], outputs: [pad]);
      async.elapse(every);
      expect(changes, 2);
      unawaited(sub.cancel());
      async.flushMicrotasks();
      final before = listed;
      async.elapse(every * 3);
      expect(listed, before);
    });
  });

  test('a failing listing leaves the call without devices, not failed', () {
    fakeAsync((async) {
      final platform = DesktopCallPlatform(
        lister: () async => throw StateError('no audio'),
        selector: ({required input, required id}) async =>
            throw StateError('unplugged'),
      );
      var devices = (inputs: [mic], outputs: [pad]);
      unawaited(platform.devices().then((d) => devices = d));
      unawaited(platform.selectDevice(input: true, id: 'mic'));
      async.flushMicrotasks();
      expect(devices.inputs, isEmpty);
      expect(devices.outputs, isEmpty);
    });
  });

  test('needs no permission and offers no routes', () async {
    final platform = DesktopCallPlatform(lister: () async => noDevices);
    expect(await platform.requestMicrophone(), isTrue);
    expect(await platform.routes(), isEmpty);
  });
}

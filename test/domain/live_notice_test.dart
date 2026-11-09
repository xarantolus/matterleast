import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/live_notice.dart';

void main() {
  test('says nothing while the connection is up', () {
    expect(liveNotice(socketDown: false, offline: false), isNull);
    expect(liveNotice(socketDown: false, offline: true), isNull);
  });

  test('connecting while the device is online, offline when it is not', () {
    expect(liveNotice(socketDown: true, offline: false), 'Connecting…');
    expect(liveNotice(socketDown: true, offline: true), 'Offline');
  });
}

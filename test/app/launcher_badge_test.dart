import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/desktop/launcher_badge.dart';
import 'package:matterleast/domain/unread_badge.dart';

void main() {
  test('the launcher shows the number only while something is unread', () {
    expect(launcherEntry(0), (count: 0, visible: false, urgent: false));
    expect(launcherEntry(3), (count: 3, visible: true, urgent: false));
    expect(launcherEntry(250), (count: 250, visible: true, urgent: false));
    expect(launcherEntry(-1), (count: 0, visible: false, urgent: false));
  });

  test('an arrival can ask the launcher for attention', () {
    expect(launcherEntry(4, urgent: true).urgent, isTrue);
  });

  test('the signal carries the properties the launchers read', () {
    final props = launcherEntryProperties(launcherEntry(7, urgent: true));

    expect(props.toNative(), {
      'count': 7,
      'count-visible': true,
      'urgent': true,
    });
    expect(props.signature, DBusSignature('a{sv}'));
  });
}

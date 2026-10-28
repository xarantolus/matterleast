import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:matterleast/domain/unread_badge.dart';
import 'package:matterleast/log.dart';

/// The unread count on the app's icon in docks that listen for the Unity
/// LauncherEntry signal (Plasma, Ubuntu Dock, Dash to Dock). On a desktop
/// without a listener the signal goes nowhere; other platforms do nothing.
class LauncherBadge {
  DBusClient? _bus;

  static const _app = 'application://io.github.xarantolus.matterleast.desktop';

  Future<void> show(LauncherEntry entry) async {
    if (!Platform.isLinux) return;
    try {
      await (_bus ??= DBusClient.session()).emitSignal(
        path: DBusObjectPath('/com/canonical/unity/launcherentry/1'),
        interface: 'com.canonical.Unity.LauncherEntry',
        name: 'Update',
        values: [DBusString(_app), launcherEntryProperties(entry)],
      );
    } on Object catch (e) {
      Log.warn('desktop', 'Updating the launcher badge failed', e);
    }
  }

  Future<void> close() async => _bus?.close();
}

/// The `a{sv}` part of the signal.
DBusDict launcherEntryProperties(LauncherEntry entry) =>
    DBusDict.stringVariant({
      'count': DBusInt64(entry.count),
      'count-visible': DBusBoolean(entry.visible),
      'urgent': DBusBoolean(entry.urgent),
    });

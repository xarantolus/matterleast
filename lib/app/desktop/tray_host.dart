import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:matterleast/log.dart';

/// Whether the desktop shows tray icons. Windows always has a notification
/// area. On Linux a tray icon is a StatusNotifierItem, shown only while a
/// panel has registered as a host with the watcher (GNOME has none without
/// an extension); panels can start or stop after the app, so it is watched.
class TrayHost {
  TrayHost._(this._bus);

  final DBusClient? _bus;
  final _changes = StreamController<bool>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  var _present = false;

  static const _watcher = 'org.kde.StatusNotifierWatcher';

  bool get present => _present;
  Stream<bool> get changes => _changes.stream;

  static Future<TrayHost> watch() async {
    if (!Platform.isLinux) return TrayHost._(null).._present = true;
    final host = TrayHost._(DBusClient.session());
    await host._start();
    return host;
  }

  Future<void> _start() async {
    final bus = _bus!;
    _subscriptions
      ..add(
        bus.nameOwnerChanged
            .where((e) => e.name == _watcher)
            .listen((_) => unawaited(_check())),
      )
      ..add(
        DBusSignalStream(
          bus,
          interface: _watcher,
          name: 'StatusNotifierHostRegistered',
        ).listen((_) => unawaited(_check())),
      );
    await _check();
  }

  Future<void> _check() async {
    final present = await _hostRegistered();
    if (present == _present) return;
    _present = present;
    _changes.add(present);
  }

  /// Any doubt counts as no tray, so a window never hides where nothing
  /// could bring it back.
  Future<bool> _hostRegistered() async {
    try {
      final watcher = DBusRemoteObject(
        _bus!,
        name: _watcher,
        path: DBusObjectPath('/StatusNotifierWatcher'),
      );
      final value = await watcher.getProperty(
        _watcher,
        'IsStatusNotifierHostRegistered',
      );
      return value is DBusBoolean && value.value;
    } on Object catch (e) {
      Log.info('desktop', 'No tray host: ${e.runtimeType}');
      return false;
    }
  }

  Future<void> close() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _changes.close();
    await _bus?.close();
  }
}

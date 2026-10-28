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
  final _items = StreamController<String>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  var _present = false;

  static const _watcher = 'org.kde.StatusNotifierWatcher';

  // The tray plugin names its item after the process id, which inside a
  // Flatpak is the same small number for every app; whoever started first
  // keeps the name and a later icon is never registered.
  static final _itemPrefix = 'org.kde.StatusNotifierItem-$pid-';

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
      )
      ..add(
        DBusSignalStream(
          bus,
          interface: _watcher,
          name: 'StatusNotifierItemRegistered',
        ).listen((signal) {
          final name = signal.values.firstOrNull;
          if (name is DBusString) _items.add(name.value);
        }),
      );
    await _check();
  }

  Future<void> _check() async {
    final present = await _hostRegistered();
    if (present == _present) return;
    _present = present;
    _changes.add(present);
  }

  /// Starts waiting for the panel to take the next tray icon of this
  /// process; make the icon after calling this, then await the result. False
  /// when it didn't within [timeout], which is when its name was taken.
  Future<bool> expectItem({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (_bus == null || !_present) return true;
    final taken = Completer<bool>();
    final sub = _items.stream
        .where((name) => name.startsWith(_itemPrefix))
        .listen((_) {
          if (!taken.isCompleted) taken.complete(true);
        });
    try {
      return await taken.future.timeout(timeout, onTimeout: () => false);
    } finally {
      await sub.cancel();
    }
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
    await _items.close();
    await _bus?.close();
  }
}

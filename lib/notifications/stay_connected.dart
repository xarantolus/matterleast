import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/notification_check.dart';

/// The opt-in foreground service, switched from the settings. Its state
/// lives with the service (so its notification's Stop action and this
/// switch agree); this only asks it. Android only: elsewhere it is off.
abstract final class StayConnected {
  static const _channel = MethodChannel('matterleast/stay_connected');

  static Future<bool> enabled() async =>
      !isDesktop && (await _channel.invokeMethod<bool>('isEnabled') ?? false);

  static Future<void> enable() => _call('enable');

  static Future<void> disable() => _call('disable');

  /// Starts the service at launch when it is switched on.
  static Future<void> resume() => _call('resume');

  static Future<void> _call(String method) async {
    if (isDesktop) return;
    await _channel.invokeMethod<void>(method);
  }
}

/// The service's own engine. It holds the WebSockets of the signed-in
/// servers while the UI is away and runs the same notification check as
/// the periodic work after each new post, without refreshing first since
/// the socket keeps the database current. While the UI is on screen it
/// lets go, so the UI's own connection is the only one.
@pragma('vm:entry-point')
Future<void> stayConnectedMain() async {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(AppVisibility.serviceName);
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    AppVisibility.serviceName,
  );
  final engine = _ServiceEngine();
  port.listen((message) {
    if (message is bool) unawaited(engine.uiVisible(message));
  });
  if (!AppVisibility.visible) await engine.connect();
}

class _ServiceEngine {
  BackgroundApp? _app;
  final _subscriptions = <StreamSubscription<Object?>>[];
  final _checks = <String, NotificationCheck>{};
  final _pending = <String>{};
  Timer? _debounce;
  var _busy = Future<void>.value();

  /// One step at a time: connecting and letting go never overlap.
  Future<void> _serial(Future<void> Function() step) =>
      _busy = _busy.then((_) => step()).catchError((Object e) {
        Log.warn('notify', 'Stay connected step failed', e);
      });

  Future<void> uiVisible(bool visible) =>
      visible ? _serial(_disconnect) : connect();

  /// Opens the servers afresh, so sign-ins and sign-outs in the UI count.
  Future<void> connect() => _serial(() async {
    if (_app != null) return;
    final app = _app = await BackgroundApp.open();
    final labels = await app.signedIn();
    for (final MapEntry(key: url, value: label) in labels.entries) {
      final session = await app.manager.session(url);
      final check = _checks[url] = NotificationCheck(
        session,
        app.notifier,
        appVisible: () => AppVisibility.visible,
        serverName: label,
      );
      _subscriptions
        ..add(
          session.connection.applied
              .where((e) => e is PostedEvent)
              .listen((_) => _soon(url)),
        )
        ..add(session.connection.caughtUp.listen((_) => _soon(url)));
      session.connection.socket.start();
      unawaited(check.run().catchError((Object _) {}));
    }
  });

  /// Posts often come in bursts; one check covers them.
  void _soon(String url) {
    _pending.add(url);
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      final urls = _pending.toList();
      _pending.clear();
      for (final url in urls) {
        unawaited(_checks[url]?.run(refresh: false).catchError((Object _) {}));
      }
    });
  }

  Future<void> _disconnect() async {
    _debounce?.cancel();
    _pending.clear();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    _checks.clear();
    await _app?.close();
    _app = null;
  }
}

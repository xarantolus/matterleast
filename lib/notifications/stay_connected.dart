import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/live_notifications.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

/// The opt-in foreground service, switched from the settings. Its state
/// lives with the service (so its notification's Stop action and this
/// switch agree); this only asks it. Android only: elsewhere it is off.
abstract final class StayConnected {
  static const _channel = MethodChannel('matterleast/stay_connected');

  static Future<bool> enabled() async =>
      hasAndroidServices &&
      (await _channel.invokeMethod<bool>('isEnabled') ?? false);

  static Future<void> enable() => _call('enable');

  static Future<void> disable() => _call('disable');

  /// Starts the service at launch when it is switched on.
  static Future<void> resume() => _call('resume');

  static Future<void> _call(String method) async {
    if (!hasAndroidServices) return;
    await _channel.invokeMethod<void>(method);
  }
}

/// Asks for the notification permission; when the system won't ask again,
/// opens its settings.
Future<void> allowNotifications(Notifier notifier) async {
  if (!await notifier.requestPermission()) await notifier.openSettings();
}

/// Switches Stay connected, asking for the notification permission first.
Future<void> setStayConnected(Notifier notifier, bool on) async {
  if (!on) return StayConnected.disable();
  if (!await notifier.permitted()) await allowNotifications(notifier);
  await StayConnected.enable();
}

/// The service's own engine. It holds the WebSockets of the signed-in
/// servers while the UI is away and runs the same notification check as
/// the periodic work after each new post, without refreshing first since
/// the socket keeps the database current. While the UI is on screen it
/// lets go, so the UI's own connection is the only one.
@pragma('vm:entry-point')
Future<void> stayConnectedMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(AppVisibility.serviceName);
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    AppVisibility.serviceName,
  );
  final engine = _ServiceEngine();
  // Android destroyed the UI, which may not have said goodbye.
  _engineChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'uiGone':
        AppVisibility.forgetUi();
        await engine.uiVisible(false);
      // The service's alarm: the device woke, so is the socket still alive?
      case 'check':
        await engine.checkAlive();
    }
  });
  port.listen((message) {
    if (AppVisibility.answerPing(message)) return;
    switch (message) {
      // The UI is shown and waits until this has let go.
      case final SendPort done:
        unawaited(engine.uiVisible(true).whenComplete(() => done.send(null)));
      case false:
        unawaited(engine.uiVisible(false));
    }
  });
  if (!await AppVisibility.stillVisible()) await engine.connect();
}

/// Notifies what arrives on [session] from now on, and first what arrived
/// since the notification cursor, so a restarted service catches up. The
/// caller starts the socket.
LiveNotifications watchServer(
  ServerSession session,
  Notifier notifier,
  String? label, {
  required bool Function(ConversationKey key) shownNow,
}) {
  final check = NotificationCheck(
    session,
    notifier,
    shownNow: shownNow,
    serverName: label,
  );
  session.connection.withoutUi(check.run);
  unawaited(check.run().catchError((Object _) {}));
  return LiveNotifications(
    applied: session.connection.applied,
    caughtUp: session.connection.caughtUp,
    check: ({required afterGap}) => check.run(refresh: false, fetch: afterGap),
  )..start();
}

const _engineChannel = MethodChannel('matterleast/stay_connected_engine');

class _ServiceEngine {
  BackgroundApp? _app;
  final _live = <LiveNotifications>[];
  final _sockets = <ServerSocket>[];
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
      final ServerSession session;
      try {
        session = await app.manager.session(url);
      } on Object catch (e) {
        // The other servers still notify.
        Log.warn('notify', 'Opening a server failed', e);
        continue;
      }
      _live.add(
        watchServer(
          session,
          app.notifier,
          label,
          shownNow: (_) => AppVisibility.visible,
        ),
      );
      _sockets.add(session.connection.socket..start());
    }
  });

  /// Pings every server's socket and reconnects the ones that don't answer.
  Future<void> checkAlive() =>
      Future.wait([..._sockets].map((s) => s.ensureAlive()));

  /// Lets go even when a step fails, so the next [connect] opens afresh
  /// instead of thinking it is still connected.
  Future<void> _disconnect() async {
    final app = _app;
    final live = [..._live];
    _app = null;
    _live.clear();
    _sockets.clear();
    for (final l in live) {
      await _quietly(l.stop);
    }
    if (app != null) await _quietly(app.close);
  }

  static Future<void> _quietly(Future<void> Function() step) async {
    try {
      await step();
    } on Object catch (e) {
      Log.warn('notify', 'Letting go of a server failed', e);
    }
  }
}

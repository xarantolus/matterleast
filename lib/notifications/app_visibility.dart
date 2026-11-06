import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

/// Whether the app's UI is on screen, readable from every isolate of the
/// process (background work, the stay-connected engine, notification
/// actions) through the isolate name server.
abstract final class AppVisibility {
  static const _name = 'matterleast.app_visible';

  /// The stay-connected engine listens here for the UI coming and going.
  static const serviceName = 'matterleast.stay_connected';

  static const _ping = 'ping';

  static ReceivePort? _port;

  static bool get visible => IsolateNameServer.lookupPortByName(_name) != null;

  /// [visible], confirmed by the UI isolate itself: one that died without
  /// [hidden], as when the app is swiped away from the recent apps, leaves
  /// its name behind.
  static Future<bool> stillVisible() => answers(_name);

  /// Whether the isolate registered under [name] answers within [wait].
  /// A name nobody answers for is forgotten.
  static Future<bool> answers(
    String name, {
    Duration wait = const Duration(seconds: 2),
  }) async {
    final port = IsolateNameServer.lookupPortByName(name);
    if (port == null) return false;
    final reply = ReceivePort();
    port.send([_ping, reply.sendPort]);
    try {
      await reply.first.timeout(wait);
      return true;
    } on TimeoutException {
      if (IsolateNameServer.lookupPortByName(name) == port) {
        IsolateNameServer.removePortNameMapping(name);
      }
      return false;
    } finally {
      reply.close();
    }
  }

  /// Answers [answers]; true when [message] was its question.
  static bool answerPing(Object? message) {
    if (message case [_ping, final SendPort reply]) {
      reply.send(null);
      return true;
    }
    return false;
  }

  /// Forgets the UI once Android has destroyed it.
  static void forgetUi() => IsolateNameServer.removePortNameMapping(_name);

  /// Called by the UI isolate as it is shown. Completes once the
  /// stay-connected engine has let go of the servers, so their databases
  /// have one writer again, or after [wait] when it doesn't answer.
  static Future<void> shown({
    Duration wait = const Duration(seconds: 5),
  }) async {
    if (_port == null) {
      _port = ReceivePort()..listen(answerPing);
      IsolateNameServer.removePortNameMapping(_name);
      IsolateNameServer.registerPortWithName(_port!.sendPort, _name);
    }
    final service = IsolateNameServer.lookupPortByName(serviceName);
    if (service == null) return;
    final done = ReceivePort();
    service.send(done.sendPort);
    try {
      await done.first.timeout(wait);
    } on TimeoutException {
      // Its databases still wait for each other; they just may wait long.
    } finally {
      done.close();
    }
  }

  /// Called by the UI isolate once it has gone quiet after being hidden.
  static void hidden() {
    IsolateNameServer.removePortNameMapping(_name);
    _port?.close();
    _port = null;
    IsolateNameServer.lookupPortByName(serviceName)?.send(false);
  }
}

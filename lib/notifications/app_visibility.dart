import 'dart:isolate';
import 'dart:ui';

/// Whether the app's UI is on screen, readable from every isolate of the
/// process (background work, the stay-connected engine, notification
/// actions) through the isolate name server.
abstract final class AppVisibility {
  static const _name = 'matterleast.app_visible';

  /// The stay-connected engine listens here for the UI coming and going.
  static const serviceName = 'matterleast.stay_connected';

  static ReceivePort? _port;

  static bool get visible => IsolateNameServer.lookupPortByName(_name) != null;

  /// Called by the UI isolate as it is shown and hidden.
  static void set({required bool visible}) {
    if (visible) {
      if (_port == null) {
        _port = ReceivePort();
        IsolateNameServer.removePortNameMapping(_name);
        IsolateNameServer.registerPortWithName(_port!.sendPort, _name);
      }
    } else {
      IsolateNameServer.removePortNameMapping(_name);
      _port?.close();
      _port = null;
    }
    IsolateNameServer.lookupPortByName(serviceName)?.send(visible);
  }
}

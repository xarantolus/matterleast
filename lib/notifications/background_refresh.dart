import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('matterleast/background_refresh');

/// Whether iOS lets the app check for messages while it is closed
/// (Background App Refresh); always true elsewhere.
Future<bool> backgroundRefreshAllowed() async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return true;
  try {
    final status = await _channel.invokeMethod<String>('status');
    return status != 'denied' && status != 'restricted';
  } on PlatformException {
    return true;
  } on MissingPluginException {
    return true;
  }
}

/// Pure: what the iOS settings say about checks while the app is closed,
/// which take the place of Android's Stay connected.
({String title, String subtitle}) backgroundCheckNotice({
  required bool refreshAllowed,
}) => refreshAllowed
    ? (
        title: 'Checks in the background',
        subtitle:
            'iOS lets Matterleast check for new messages while it is closed '
            'when iOS allows, often much less than every 15 minutes. Open '
            'the app to get messages right away.',
      )
    : (
        title: 'Background App Refresh is off',
        subtitle:
            "iOS doesn't let Matterleast check for new messages while it is "
            'closed. Turn on Background App Refresh for Matterleast in '
            'Settings.',
      );

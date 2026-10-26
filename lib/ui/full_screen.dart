import 'package:flutter/services.dart';

const _display = MethodChannel('matterleast/display');

/// Whether the user lets the screen follow the device's rotation; false
/// when the platform can't tell.
Future<bool> autoRotateEnabled() async {
  try {
    return await _display.invokeMethod<bool>('autoRotate') ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

/// Hides the system bars and, for wide content when the user allows
/// rotation, turns the screen to landscape.
Future<void> enterFullScreen({required bool wide}) async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  if (wide && await autoRotateEnabled()) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

Future<void> leaveFullScreen() async {
  await SystemChrome.setPreferredOrientations(const []);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

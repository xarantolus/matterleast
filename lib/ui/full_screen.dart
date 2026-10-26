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

/// Pure: the orientations full screen locks to. Only wide content turns
/// the screen, and only when the user lets it rotate; empty keeps the
/// app's own orientation.
List<DeviceOrientation> fullScreenOrientations({
  required bool wide,
  required bool autoRotate,
}) => wide && autoRotate
    ? const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
    : const [];

/// Hides the system bars and, for wide content when the user allows
/// rotation, turns the screen to landscape.
Future<void> enterFullScreen({required bool wide}) async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final orientations = fullScreenOrientations(
    wide: wide,
    autoRotate: wide && await autoRotateEnabled(),
  );
  if (orientations.isNotEmpty) {
    await SystemChrome.setPreferredOrientations(orientations);
  }
}

Future<void> leaveFullScreen() async {
  await SystemChrome.setPreferredOrientations(const []);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

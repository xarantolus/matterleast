import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:matterleast/log.dart';

/// Linux: opens [path] through the desktop's OpenURI portal, which works
/// the same inside the Flatpak sandbox (where the host's apps are out of
/// reach) and outside it. With [ask] the desktop lets the person pick the
/// app. False when no portal answers, so the caller can fall back to
/// `xdg-open`.
Future<bool> openFileWithPortal(String path, {required bool ask}) async {
  final bus = DBusClient.session();
  RandomAccessFile? file;
  try {
    file = await File(path).open();
    final portal = DBusRemoteObject(
      bus,
      name: 'org.freedesktop.portal.Desktop',
      path: DBusObjectPath('/org/freedesktop/portal/desktop'),
    );
    // The portal answers with a request handle at once; the app opens (or
    // the chooser is cancelled) later, which needs no answer from us.
    await portal.callMethod('org.freedesktop.portal.OpenURI', 'OpenFile', [
      DBusString(''),
      DBusUnixFd(ResourceHandle.fromFile(file)),
      DBusDict.stringVariant({'ask': DBusBoolean(ask)}),
    ], replySignature: DBusSignature('o'));
    return true;
  } on Object catch (e) {
    Log.info('files', 'The open-file portal failed: ${e.runtimeType}');
    return false;
  } finally {
    await file?.close();
    await bus.close();
  }
}

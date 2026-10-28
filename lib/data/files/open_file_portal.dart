import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:matterleast/log.dart';

/// Linux: opens [path] through the OpenURI portal, which reaches the host's
/// apps from inside the Flatpak too; false when no portal answers.
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

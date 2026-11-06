import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:matterleast/log.dart';

/// How the desktop answered a request to open a file.
enum PortalOutcome { opened, dismissed, failed }

/// Pure: the OpenURI portal's Response code as an outcome; 1 is the person
/// closing the app chooser, everything else but 0 is a failure.
PortalOutcome portalOutcome(int response) => switch (response) {
  0 => PortalOutcome.opened,
  1 => PortalOutcome.dismissed,
  _ => PortalOutcome.failed,
};

/// Pure: the object path the portal answers on for a request that [sender]
/// (a bus unique name such as `:1.42`) made with [token].
String portalRequestPath(String sender, String token) =>
    '/org/freedesktop/portal/desktop/request/'
    '${sender.substring(1).replaceAll('.', '_')}/$token';

const _chooserPatience = Duration(minutes: 10);

/// Linux: opens [path] through the OpenURI portal, which reaches the host's
/// apps from inside the Flatpak too, and waits for the portal's answer.
/// [ask] shows the desktop's app chooser.
Future<PortalOutcome> openFileWithPortal(
  String path, {
  required bool ask,
  DBusClient? bus,
}) async {
  final client = bus ?? DBusClient.session();
  RandomAccessFile? file;
  try {
    await client.ping();
    file = await File(path).open();
    final token = 'matterleast_${DateTime.now().microsecondsSinceEpoch}';
    final request = portalRequestPath(client.uniqueName, token);
    // The answer can arrive before the call returns, so listen first.
    final response = DBusSignalStream(
      client,
      sender: 'org.freedesktop.portal.Desktop',
      interface: 'org.freedesktop.portal.Request',
      name: 'Response',
      path: DBusObjectPath(request),
    ).first;
    final portal = DBusRemoteObject(
      client,
      name: 'org.freedesktop.portal.Desktop',
      path: DBusObjectPath('/org/freedesktop/portal/desktop'),
    );
    await portal.callMethod('org.freedesktop.portal.OpenURI', 'OpenFile', [
      DBusString(''),
      DBusUnixFd(ResourceHandle.fromFile(file)),
      DBusDict.stringVariant({
        'ask': DBusBoolean(ask),
        'handle_token': DBusString(token),
      }),
    ], replySignature: DBusSignature('o'));
    final signal = await response.timeout(_chooserPatience);
    return portalOutcome(signal.values.first.asUint32());
  } on Object catch (e) {
    Log.info('files', 'The open-file portal failed: ${e.runtimeType}');
    return PortalOutcome.failed;
  } finally {
    await file?.close();
    if (bus == null) await client.close();
  }
}

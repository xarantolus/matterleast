import 'package:flutter/foundation.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';

/// `address|username|password` for the local test server, so each
/// development emulator starts signed in (`tool/lane.sh`). Never set in
/// release builds.
const _devLogin = String.fromEnvironment('MATTERLEAST_DEV_LOGIN');

/// Adds and signs in to the development server when no server is stored yet.
Future<void> devSignIn(ServerManager manager, List<String> storedUrls) async {
  if (kReleaseMode || _devLogin.isEmpty || storedUrls.isNotEmpty) return;
  final [address, username, password] = _devLogin.split('|');
  final server = await ServerProbe().probe(address);
  final signedIn = await SignIn().withPassword(
    server,
    loginId: username,
    password: password,
  );
  await manager.addSignedIn(
    server: server,
    displayName: server.options.siteName,
    signedIn: signedIn,
  );
}

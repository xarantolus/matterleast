import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/ui/confirm_dialog.dart';

/// Signs out of [server] and removes it from the device, after asking.
/// When the server can't be told it offers to sign out here anyway. The
/// one path for the You page and the list of sessions.
Future<void> leaveServer(
  BuildContext context,
  WidgetRef ref,
  ServerEntry server,
) async {
  // The tile goes away with a removed server, so nothing reads ref later.
  final manager = ref.read(serverManagerProvider);
  final db = ref.read(appDatabaseProvider);
  final navigator = Navigator.of(context);
  final confirmed = await confirm(
    context,
    title: server.signedIn
        ? 'Sign out of ${server.displayName}?'
        : 'Remove ${server.displayName}?',
    body:
        'The server and everything saved from it are removed from this '
        'device. To use it again, add it again.',
    action: server.signedIn ? 'Sign out' : 'Remove',
    destructive: true,
  );
  if (!confirmed) return;
  Future<bool> run({bool force = false}) =>
      manager.remove(server.url, force: force);
  var done = await run();
  if (!done && context.mounted) {
    final anyway = await confirm(
      context,
      title: "Couldn't sign out on ${server.address}",
      body:
          'Sign out on this device anyway? The session stays valid on the '
          'server until it expires.',
      action: 'Sign out anyway',
    );
    if (anyway) done = await run(force: true);
  }
  final anySignedIn = (await db.allServers()).any(
    (s) => s.lastActiveAt != null,
  );
  if (done && !anySignedIn) {
    outsidePopout(navigator).popUntil((route) => route.isFirst);
  }
}

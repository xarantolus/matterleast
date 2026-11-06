import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/magic_link_sign_in.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/magic_link.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/slide_route.dart';

/// Opens a link another app handed over, only when it points into a server
/// the user is signed in to; anything else is refused, never forwarded. A
/// guest's emailed sign-in link is the exception: it signs in.
Future<void> openIncomingLink(NavigatorState navigator, Uri uri) async {
  if (!navigator.mounted) return;
  if (parseMagicLink(uri) case final magic?) {
    await _signInWithMagicLink(navigator, magic);
    return;
  }
  final servers = await ProviderScope.containerOf(
    navigator.context,
    listen: false,
  ).read(serversProvider.future);
  final signedIn = [
    for (final s in servers)
      if (s.signedIn) Uri.parse(s.url),
  ];
  final link = parseIncomingLink(uri, signedIn);
  if (!navigator.mounted) return;
  if (link == null) {
    final web = uri.scheme == 'https' || uri.scheme == 'http';
    ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
      SnackBar(
        content: const Text(
          "That link is on a server you aren't signed in to.",
        ),
        action: web && uri.host.isNotEmpty
            ? SnackBarAction(
                label: 'Add server',
                onPressed: () => navigator.push(
                  SlideRoute<void>.page(
                    builder: (_) => AddServerScreen(initialUrl: uri.toString()),
                  ),
                ),
              )
            : null,
      ),
    );
    return;
  }
  await openLinkFromMessage(
    navigator,
    uri.replace(scheme: link.server.scheme, port: link.server.port),
    fromOutside: true,
  );
}

Future<void> _signInWithMagicLink(
  NavigatorState navigator,
  MagicLink link,
) async {
  final signIn = ProviderScope.containerOf(
    navigator.context,
    listen: false,
  ).read(magicLinkSignInProvider);
  // Any page or app can open such a link, so it never signs in unasked.
  final host = link.server.authority;
  final asked = await confirm(
    navigator.context,
    title: 'Sign in to $host?',
    body:
        'A sign-in link for $host was opened. Continue only if you asked '
        '$host for this link.',
    action: 'Sign in',
  );
  if (!asked || !navigator.mounted) return;
  try {
    await signIn.signIn(link);
  } on LoginRejected catch (e) {
    if (!navigator.mounted) return;
    ScaffoldMessenger.maybeOf(navigator.context)
        ?.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

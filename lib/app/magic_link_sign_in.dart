import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/sso_resume.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/magic_link.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'magic_link_sign_in.g.dart';

/// Signs in with a guest's emailed link, for a server the app may not know
/// yet. Everything that goes wrong is a [LoginRejected] with words for the
/// user.
class MagicLinkSignIn {
  MagicLinkSignIn(this._ref);

  final Ref _ref;

  Future<void> signIn(MagicLink link) async {
    final servers = await _ref.read(serversProvider.future);
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) Uri.parse(s.url),
    ];
    if (parseServerLink(link.server, signedIn) != null) {
      throw const LoginRejected(
        'You are already logged in to this server. Log out and follow the '
        'link again.',
      );
    }
    final ProbedServer server;
    try {
      server = await _ref.read(serverProbeProvider).probe('${link.server}');
    } on ProbeFailure catch (e) {
      throw LoginRejected(e.message);
    }
    final signInResult = await _ref
        .read(signInProvider)
        .withMagicLink(server, link.token);
    final known = [
      for (final s in servers)
        if (s.url == server.url.toString()) s,
    ];
    await storeSignIn(
      _ref,
      server: server,
      displayName: known.isNotEmpty
          ? known.first.displayName
          : defaultDisplayName(server.options.siteName, server.url, [
              for (final s in servers) s.displayName,
            ]),
      signedIn: signInResult,
      ssoScheme: known.firstOrNull?.ssoScheme,
    );
  }
}

@Riverpod(keepAlive: true)
MagicLinkSignIn magicLinkSignIn(Ref ref) => MagicLinkSignIn(ref);

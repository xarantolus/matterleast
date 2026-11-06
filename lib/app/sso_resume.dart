import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/browser_auth_session.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sso_resume.g.dart';

/// Stores a session the server granted and shows that server's teams. The
/// one way a sign-in ends, whether the app waited for it or was restarted
/// meanwhile.
Future<void> storeSignIn(
  Ref ref, {
  required ProbedServer server,
  required String displayName,
  required SignedIn signedIn,
  String? ssoScheme,
  String? replaces,
  String? loginId,
}) async {
  await ref
      .read(serverManagerProvider)
      .addSignedIn(
        server: server,
        displayName: displayName,
        signedIn: signedIn,
        ssoScheme: ssoScheme,
        replaces: replaces,
        loginId: loginId,
      );
  if (ref.mounted) {
    ref
        .read(railSelectionProvider.notifier)
        .select(RailTarget(url: server.url.toString()));
  }
}

/// Finishes a browser sign-in whose callback reaches an app that no longer
/// waits for it, because Android ended the app while the user was in the
/// browser.
class SsoResume {
  SsoResume(this._ref, {this._clock = DateTime.now});

  final Ref _ref;
  final DateTime Function() _clock;

  /// True when [callback] finished a saved sign-in. A callback counts once,
  /// and only within [browserSignInTimeout] of the sign-in's start.
  Future<bool> resume(Uri callback) async {
    final store = _ref.read(pendingSsoStoreProvider);
    final pending = await store.load();
    if (pending == null) {
      Log.warn('sso', 'Ignored a sign-in callback: no sign-in is waiting');
      return false;
    }
    await store.clear();
    if (!pending.isFresh(_clock(), browserSignInTimeout)) {
      Log.warn('sso', 'Ignored a sign-in callback: the sign-in timed out');
      return false;
    }
    try {
      final server = await _ref
          .read(serverProbeProvider)
          .probe(pending.serverUrl);
      final signedIn = await _ref
          .read(signInProvider)
          .finishSso(server, pending.scheme, pending.challenge, callback);
      await storeSignIn(
        _ref,
        server: server,
        displayName: pending.displayName,
        signedIn: signedIn,
        ssoScheme: pending.ssoScheme,
        replaces: pending.replaces,
      );
      return true;
    } on Exception catch (e, stack) {
      Log.error(
        'sso',
        'Finishing the sign-in after a restart failed',
        e,
        stack,
      );
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
SsoResume ssoResume(Ref ref) => SsoResume(ref);

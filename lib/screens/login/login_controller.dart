import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/sso_resume.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/magic_link.dart';
import 'package:matterleast/domain/pending_sso.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.freezed.dart';
part 'login_controller.g.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool busy,
    @Default(false) bool mfaNeeded,

    /// Waiting for the sign-in to finish in the browser.
    @Default(false) bool inBrowser,
    String? error,
    String? mfaError,

    /// With magic links on: what the server said about the login id. Null
    /// until asked, empty when a password is the way in.
    String? loginType,

    /// The server emailed a sign-in link.
    @Default(false) bool linkSent,
  }) = _LoginState;
}

@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build(String url) => const LoginState();

  Future<bool> withPassword(
    LoginTarget target, {
    required String loginId,
    required String password,
    required String mfaCode,
  }) => _attempt(
    target,
    loginId: loginId.trim(),
    () => ref
        .read(signInProvider)
        .withPassword(
          target.server,
          loginId: loginId,
          password: password,
          mfaCode: state.mfaNeeded ? mfaCode : null,
        ),
  );

  /// With magic links on, asks how [loginId] signs in before the password
  /// field shows; the server emails a link to a guest as part of the answer.
  Future<void> checkLoginType(LoginTarget target, String loginId) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, error: null);
    try {
      final type = await ref
          .read(signInProvider)
          .loginType(target.server, loginId);
      if (!ref.mounted) return;
      state = type == magicLinkType
          ? state.copyWith(busy: false, linkSent: true)
          : state.copyWith(busy: false, loginType: type);
    } on LoginRejected catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e.message);
    }
  }

  /// Back to asking for the login id.
  void editLoginId() => state = const LoginState();

  /// Signs in with the link from the email, pasted as the server wrote it.
  Future<bool> withMagicLink(LoginTarget target, String pasted) {
    final link = parseMagicLink(Uri.tryParse(pasted.trim()) ?? Uri());
    if (link == null) {
      state = state.copyWith(error: "That isn't a sign-in link.");
      return Future.value(false);
    }
    if (parseServerLink(link.server, [target.server.url]) == null) {
      state = state.copyWith(error: 'That link is for another server.');
      return Future.value(false);
    }
    return _attempt(
      target,
      () => ref.read(signInProvider).withMagicLink(target.server, link.token),
    );
  }

  Future<bool> withSso(LoginTarget target, SsoButton button) async {
    final store = ref.read(pendingSsoStoreProvider);
    try {
      return await _attempt(
        target,
        inBrowser: true,
        () => ref
            .read(signInProvider)
            .withSso(
              target.server,
              button,
              scheme: target.ssoScheme ?? defaultSsoScheme,
              onStarted: (challenge) => store.save(
                PendingSso(
                  serverUrl: target.server.url.toString(),
                  displayName: target.displayName,
                  ssoScheme: target.ssoScheme,
                  replaces: target.replaces?.url,
                  state: challenge.state,
                  verifier: challenge.verifier,
                  startedAt: DateTime.now(),
                ),
              ),
            ),
      );
    } finally {
      await store.clear();
    }
  }

  /// Stops waiting for the browser; the login form comes back.
  void cancelBrowser() => ref.read(browserAuthSessionProvider).cancel();

  /// Signs in and stores the server; true when the user is signed in.
  Future<bool> _attempt(
    LoginTarget target,
    Future<SignedIn?> Function() signIn, {
    String? loginId,
    bool inBrowser = false,
  }) async {
    if (state.busy) return false;
    state = state.copyWith(
      busy: true,
      inBrowser: inBrowser,
      error: null,
      mfaError: null,
    );
    try {
      final SignedIn? signedIn;
      try {
        signedIn = await signIn();
      } finally {
        if (ref.mounted && state.inBrowser) {
          state = state.copyWith(inBrowser: false);
        }
      }
      if (signedIn == null) {
        if (ref.mounted) state = state.copyWith(busy: false);
        return false;
      }
      await storeSignIn(
        ref,
        server: target.server,
        displayName: target.displayName,
        signedIn: signedIn,
        ssoScheme: target.ssoScheme,
        replaces: target.replaces?.url,
        loginId: loginId,
      );
      return true;
    } on MfaCodeNeeded {
      if (ref.mounted) {
        state = LoginState(mfaNeeded: true, loginType: state.loginType);
      }
      return false;
    } on LoginRejected catch (e) {
      if (ref.mounted) {
        state = e.mfaCodeWrong
            ? LoginState(
                mfaNeeded: true,
                mfaError: e.message,
                loginType: state.loginType,
              )
            : state.copyWith(busy: false, error: e.message);
      }
      return false;
    } on Exception catch (e, stack) {
      Log.error('login', 'Saving the sign-in failed', e, stack);
      if (ref.mounted) {
        state = state.copyWith(
          busy: false,
          error: "Signed in, but the app couldn't save it. Try again.",
        );
      }
      return false;
    }
  }
}

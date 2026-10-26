import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/add_server/add_server_controller.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.freezed.dart';
part 'login_controller.g.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool busy,
    @Default(false) bool mfaNeeded,
    String? error,
    String? mfaError,
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

  Future<bool> withSso(LoginTarget target, SsoButton button) => _attempt(
    target,
    () => ref
        .read(signInProvider)
        .withSso(
          target.server,
          button,
          scheme: target.ssoScheme ?? defaultSsoScheme,
        ),
  );

  /// Signs in and stores the server; true when the user is signed in.
  Future<bool> _attempt(
    LoginTarget target,
    Future<SignedIn?> Function() signIn, {
    String? loginId,
  }) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null, mfaError: null);
    try {
      final signedIn = await signIn();
      if (signedIn == null) {
        if (ref.mounted) state = state.copyWith(busy: false);
        return false;
      }
      await ref
          .read(serverManagerProvider)
          .addSignedIn(
            server: target.server,
            displayName: target.displayName,
            signedIn: signedIn,
            ssoScheme: target.ssoScheme,
            replaces: target.replaces?.url,
            loginId: loginId,
          );
      if (ref.mounted) {
        ref.read(railSelectionProvider.notifier).select(RailTarget(url: url));
      }
      return true;
    } on MfaCodeNeeded {
      if (ref.mounted) state = const LoginState(mfaNeeded: true);
      return false;
    } on LoginRejected catch (e) {
      if (ref.mounted) {
        state = e.mfaCodeWrong
            ? LoginState(mfaNeeded: true, mfaError: e.message)
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

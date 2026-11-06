import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';

/// A session the server granted, confirmed by reading the user it belongs to.
class SignedIn {
  const SignedIn({required this.token, required this.me});
  final String token;
  final api.User me;
}

/// Opens [url] in an auth session and returns the redirect it ended on.
typedef OpenAuthSession = Future<Uri> Function(Uri url, String scheme);

/// Gets a session token from a server, by password or through SSO. Failures
/// are thrown as [LoginProblem]s.
class SignIn {
  SignIn({
    OpenAuthSession? openAuthSession,
    OpenAuthSession? openExternalAuthSession,
  }) : _openAuthSession = openAuthSession,
       _openExternalAuthSession = openExternalAuthSession ?? openAuthSession;

  final OpenAuthSession? _openAuthSession;

  /// For servers that want the full browser, not a Custom Tab.
  final OpenAuthSession? _openExternalAuthSession;

  Future<SignedIn> withPassword(
    ProbedServer server, {
    required String loginId,
    required String password,
    String? mfaCode,
    bool ldapOnly = false,
  }) {
    final sentCode = mfaCode != null && mfaCode.isNotEmpty;
    return _login(server, {
      'login_id': loginId.trim().toLowerCase(),
      'password': password,
      if (sentCode) 'token': mfaCode.trim(),
      if (ldapOnly) 'ldap_only': 'true',
    }, sentMfaCode: sentCode);
  }

  /// Signs in with the one-time token of a guest's emailed link.
  Future<SignedIn> withMagicLink(ProbedServer server, String token) => _login(
    server,
    api.ApiV4UsersLoginRequestBody(
      magicLinkToken: token,
      deviceId: '',
    ).toJson(),
    sentMfaCode: false,
  );

  /// The auth service the server names for [loginId]: `magic_link` when it
  /// has just emailed that account a sign-in link, empty for any other.
  Future<String> loginType(ProbedServer server, String loginId) async {
    final client = ServerApi(baseUrl: server.url, token: () => null);
    try {
      final response = await client.call(
        () => client.client.users.getLoginType(
          body: api.ApiV4UsersLoginTypeRequestBody(
            loginId: loginId.trim().toLowerCase(),
            deviceId: '',
          ),
        ),
      );
      return response.authService ?? '';
    } on ApiError catch (e) {
      throw LoginRejected(serverSaidText(e, server.url.authority));
    } finally {
      client.close();
    }
  }

  Future<SignedIn> _login(
    ProbedServer server,
    Map<String, Object?> data, {
    required bool sentMfaCode,
  }) async {
    final host = server.url.authority;
    final client = ServerApi(baseUrl: server.url, token: () => null);
    try {
      final response = await client.call(
        () => client.dio.post<Object?>(
          '/api/v4/users/login',
          data: data,
          options: Options(headers: {'Cache-Control': 'no-store'}),
        ),
      );
      final token = response.headers.value('token');
      if (token == null || token.isEmpty) {
        throw LoginRejected('$host signed in but sent no session. Try again.');
      }
      return await _confirm(server, token);
    } on ApiError catch (e) {
      throw loginProblemFrom(e, sentMfaCode: sentMfaCode, host: host);
    } finally {
      client.close();
    }
  }

  /// Asks the server to email a password reset link. The server answers the
  /// same whether or not the address has an account.
  Future<void> sendPasswordReset(ProbedServer server, String email) async {
    final client = ServerApi(baseUrl: server.url, token: () => null);
    try {
      await client.call(
        () => client.client.users.sendPasswordResetEmail(
          body: api.ApiV4UsersPasswordResetSendRequestBody(email: email.trim()),
        ),
      );
    } finally {
      client.close();
    }
  }

  /// Runs the provider's login in an auth session. Returns null when the user
  /// closed it. [onStarted] gets the sign-in's challenge before the browser
  /// opens.
  Future<SignedIn?> withSso(
    ProbedServer server,
    SsoButton button, {
    String scheme = defaultSsoScheme,
    Future<void> Function(SsoChallenge challenge)? onStarted,
  }) async {
    final open = server.options.externalBrowserForSso
        ? _openExternalAuthSession
        : _openAuthSession;
    if (open == null) throw StateError('This SignIn has no auth session');
    final challenge = SsoChallenge.generate();
    await onStarted?.call(challenge);
    final Uri callback;
    try {
      callback = await open(
        ssoStartUrl(
          server: server.url,
          path: button.path,
          scheme: scheme,
          challenge: challenge,
        ),
        scheme,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return null;
      throw LoginRejected(
        "The sign-in page couldn't be opened. Check that a browser is "
        'installed and try again.',
      );
    }
    return finishSso(server, scheme, challenge, callback);
  }

  /// Checks the redirect [callback] of a sign-in started with [challenge] and
  /// turns it into a session.
  Future<SignedIn> finishSso(
    ProbedServer server,
    String scheme,
    SsoChallenge challenge,
    Uri callback,
  ) async {
    final result = parseSsoCallback(
      callback,
      scheme: scheme,
      server: server.url,
      siteUrl: server.options.siteUrl,
      serverVersion: server.options.serverVersion,
      state: challenge.state,
      codeExchange: server.options.ssoCodeExchange,
    );
    return switch (result) {
      SsoToken(:final token) => await _confirm(server, token),
      SsoCode(:final loginCode) => await _confirm(
        server,
        await _exchange(server, loginCode, challenge),
      ),
      SsoRejected(:final reason) => throw LoginRejected('$reason Try again.'),
    };
  }

  /// Redeems the one-time code the server sent for the session token.
  Future<String> _exchange(
    ProbedServer server,
    String loginCode,
    SsoChallenge challenge,
  ) async {
    final client = ServerApi(baseUrl: server.url, token: () => null);
    try {
      final response = await client.call(
        () => client.dio.post<Map<String, Object?>>(
          '/api/v4/users/login/sso/code-exchange',
          data: api.ApiV4UsersLoginSsoCodeExchangeRequestBody(
            loginCode: loginCode,
            codeVerifier: challenge.verifier,
            state: challenge.state,
          ).toJson(),
          options: Options(headers: {'Cache-Control': 'no-store'}),
        ),
      );
      final data = response.data;
      final token = data == null
          ? null
          : api.PostApiV4UsersLoginSsoCodeExchangeResponse.fromJson(data).token;
      if (token == null || token.isEmpty) {
        throw LoginRejected(
          '${server.url.authority} signed in but sent no session. Try again.',
        );
      }
      return token;
    } on ApiError catch (e) {
      throw loginProblemFrom(e, sentMfaCode: false, host: server.url.authority);
    } finally {
      client.close();
    }
  }

  /// Reads the user with the new token. This also catches a server that
  /// enforces two-factor authentication the user has not set up: login works,
  /// every other call answers 403.
  Future<SignedIn> _confirm(ProbedServer server, String token) async {
    final client = ServerApi(baseUrl: server.url, token: () => token);
    try {
      final me = await client.call(
        () => client.client.users.getUser(userId: 'me'),
      );
      return SignedIn(token: token, me: me);
    } on ApiError catch (e) {
      throw loginProblemFrom(e, sentMfaCode: false, host: server.url.authority);
    } finally {
      client.close();
    }
  }
}

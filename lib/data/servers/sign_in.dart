import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
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

// A plain Custom Tab sharing the browser session, as the official Android
// app does; the redirect comes back through the plugin's CallbackActivity.
Future<Uri> _openAuthTab(Uri url, String scheme) async => Uri.parse(
  await FlutterWebAuth2.authenticate(
    url: url.toString(),
    callbackUrlScheme: scheme,
    options: const FlutterWebAuth2Options(preferEphemeral: false),
  ),
);

/// Gets a session token from a server, by password or through SSO. Failures
/// are thrown as [LoginProblem]s.
class SignIn {
  SignIn({OpenAuthSession? openAuthSession})
    : _openAuthSession = openAuthSession ?? _openAuthTab;

  final OpenAuthSession _openAuthSession;

  Future<SignedIn> withPassword(
    ProbedServer server, {
    required String loginId,
    required String password,
    String? mfaCode,
    bool ldapOnly = false,
  }) async {
    final host = server.url.authority;
    final sentCode = mfaCode != null && mfaCode.isNotEmpty;
    final client = ServerApi(baseUrl: server.url, token: () => null);
    try {
      final response = await client.call(
        () => client.dio.post<Object?>(
          '/api/v4/users/login',
          data: {
            'login_id': loginId.trim().toLowerCase(),
            'password': password,
            if (sentCode) 'token': mfaCode.trim(),
            if (ldapOnly) 'ldap_only': 'true',
          },
          options: Options(headers: {'Cache-Control': 'no-store'}),
        ),
      );
      final token = response.headers.value('token');
      if (token == null || token.isEmpty) {
        throw LoginRejected('$host signed in but sent no session. Try again.');
      }
      return await _confirm(server, token);
    } on ApiError catch (e) {
      throw loginProblemFrom(e, sentMfaCode: sentCode, host: host);
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
  /// closed it.
  Future<SignedIn?> withSso(
    ProbedServer server,
    SsoButton button, {
    String scheme = defaultSsoScheme,
  }) async {
    final challenge = SsoChallenge.generate();
    final Uri callback;
    try {
      callback = await _openAuthSession(
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
    final result = parseSsoCallback(
      callback,
      scheme: scheme,
      server: server.url,
      siteUrl: server.options.siteUrl,
      serverVersion: server.options.serverVersion,
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

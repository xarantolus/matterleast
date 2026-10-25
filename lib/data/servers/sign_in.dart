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

Future<Uri> _openAuthTab(Uri url, String scheme) async => Uri.parse(
  await FlutterWebAuth2.authenticate(
    url: url.toString(),
    callbackUrlScheme: scheme,
    options: const FlutterWebAuth2Options(preferEphemeral: true),
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
    final host = server.url.host;
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

  /// Runs the provider's login in an auth session. Returns null when the user
  /// closed it.
  Future<SignedIn?> withSso(
    ProbedServer server,
    SsoButton button, {
    String scheme = defaultSsoScheme,
  }) async {
    final Uri callback;
    try {
      callback = await _openAuthSession(
        ssoStartUrl(server: server.url, path: button.path, scheme: scheme),
        scheme,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return null;
      throw LoginRejected(
        "The sign-in page couldn't be opened. Check that a browser is "
        'installed and try again.',
      );
    }
    return switch (parseSsoCallback(callback, server: server.url)) {
      SsoToken(:final token) => await _confirm(server, token),
      SsoRejected(:final reason) => throw LoginRejected('$reason Try again.'),
    };
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
      throw loginProblemFrom(e, sentMfaCode: false, host: server.url.host);
    } finally {
      client.close();
    }
  }
}

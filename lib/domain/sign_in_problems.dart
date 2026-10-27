import 'dart:async';

import 'package:matterleast/api/api_error.dart';

const notMattermostText =
    "This address doesn't answer as a Mattermost server. Check the URL.";

const httpNotAllowedText =
    'Plain http:// addresses are not allowed. Use the https:// address.';

const invalidAddressText =
    "Enter the server's address, for example chat.example.com.";

/// Why [typed] is not a server address, for the field's error line.
String addressProblemText(String typed) {
  final text = typed.trim();
  if (text.isEmpty) return invalidAddressText;
  final scheme = RegExp(r'^([^:/\s]*)://').firstMatch(text)?.group(1);
  if (scheme != null && scheme != 'https' && scheme != 'http') {
    return scheme.isEmpty
        ? 'The address starts with “://”. Start with https:// or leave it '
              'out.'
        : "“$scheme://” isn't a web address. Start with https:// or leave it "
              'out.';
  }
  return "“$text” isn't a server address. Check it for typos, for example "
      'chat.example.com.';
}

const wrongCredentialsText = 'The email and password combination is incorrect.';

const mfaSetupNeededText =
    'This server requires two-factor authentication. Set it up in the web '
    'app, then sign in again.';

const keyringUnavailableText =
    "Matterleast can't reach the system keyring, where it keeps your "
    'sign-in. Make sure a keyring such as GNOME Keyring or KWallet is '
    'running and unlocked, then try again.';

/// Words for a request that never got a usable answer from [host].
String connectionProblemText(ApiError error, String host) => switch (error) {
  Unreachable(noNetwork: true) =>
    "You're offline. The app updates when the connection is back.",
  Unreachable(serverDown: true) =>
    "Can't reach $host right now. The app updates when it answers again.",
  Unreachable() =>
    "Couldn't reach $host. Check the address and your connection.",
  RequestTimeout() => "$host didn't answer in time. Try again.",
  UntrustedCertificate() =>
    "$host's certificate isn't trusted, so the app didn't connect. Check the "
        "address, or ask the server's admin about the certificate.",
  Cancelled() => 'The request was stopped.',
  KeyringUnavailable() => keyringUnavailableText,
  UnexpectedFailure(:final type) =>
    "$host's answer couldn't be read ($type). Try again later.",
  ServerError(:final message?) when message.trim().isNotEmpty =>
    '$host said: ${message.trim()}',
  ServerError(statusCode: 401) =>
    'Your session on $host has ended. Sign in again.',
  ServerError(statusCode: 403) => "$host doesn't allow this for your account.",
  ServerError(statusCode: 404) =>
    "$host couldn't find it. It may have been deleted.",
  ServerError(statusCode: 429) =>
    '$host is getting too many requests. Wait a moment, then try again.',
  ServerError(statusCode: 501) => 'This is turned off on $host.',
  ServerError(:final statusCode) =>
    '$host answered with an error ($statusCode). Try again later.',
};

/// A few words for a small space, such as a file that didn't upload.
String shortProblemText(ApiError error) => switch (error) {
  ServerError(:final message?) when message.trim().isNotEmpty => message.trim(),
  ServerError(statusCode: 403) => 'Not allowed',
  ServerError(statusCode: 413) => 'Too large for the server',
  ServerError(statusCode: 501) => 'Turned off on this server',
  ServerError(:final statusCode) => 'Server error $statusCode',
  Unreachable(noNetwork: true) => 'Offline',
  Unreachable(serverDown: true) => 'Server not answering',
  Unreachable() => 'No connection',
  RequestTimeout() => 'No answer in time',
  UntrustedCertificate() => 'Untrusted certificate',
  Cancelled() => 'Stopped',
  KeyringUnavailable() => 'Keyring unavailable',
  UnexpectedFailure() => 'Unreadable answer',
};

/// The notice over saved data after a failed refresh: offline only when no
/// answer arrived, else what went wrong in a few words.
String staleDataNotice(ApiError error) => switch (error) {
  Unreachable(serverDown: true) =>
    "Can't reach the server · showing saved data",
  Unreachable() => 'Offline · showing saved data',
  RequestTimeout() => "Couldn't update: the server didn't answer in time",
  ServerError(:final statusCode) => "Couldn't update: server error $statusCode",
  UnexpectedFailure() => "Couldn't read the server's reply",
  UntrustedCertificate() => "Couldn't update: untrusted certificate",
  Cancelled() => "Couldn't update: stopped",
  KeyringUnavailable() => "Couldn't update: the keyring is unavailable",
};

/// Words for any failed request to [host], including our own timeouts.
String requestProblemText(Object error, String host) => switch (error) {
  ApiError() => connectionProblemText(error, host),
  TimeoutException() => connectionProblemText(const RequestTimeout(), host),
  _ => 'Something went wrong talking to $host. Try again.',
};

/// Words for a failed server check; any HTTP error means the address is not
/// (or not only) a Mattermost server.
String probeProblemText(ApiError error, String host) => error is ServerError
    ? notMattermostText
    : connectionProblemText(error, host);

/// What the login screen does with a failed `POST /users/login` or the
/// `GET /users/me` that confirms it.
sealed class LoginProblem implements Exception {
  const LoginProblem();
}

/// The account has two-factor authentication: ask for the code.
final class MfaCodeNeeded extends LoginProblem {
  const MfaCodeNeeded();
}

final class LoginRejected extends LoginProblem {
  const LoginRejected(this.message, {this.mfaCodeWrong = false});
  final String message;
  final bool mfaCodeWrong;
}

const _mfaIds = {
  'mfa.validate_token.authenticate.app_error',
  'ent.mfa.validate_token.authenticate.app_error',
};

LoginProblem loginProblemFrom(
  ApiError error, {
  required bool sentMfaCode,
  required String host,
}) {
  if (error is! ServerError) {
    return LoginRejected(connectionProblemText(error, host));
  }
  final id = error.id ?? '';
  if (_mfaIds.contains(id)) {
    return sentMfaCode
        ? const LoginRejected(
            "That code didn't work. Enter the current code from your "
            'authenticator app.',
            mfaCodeWrong: true,
          )
        : const MfaCodeNeeded();
  }
  if (id.startsWith('api.user.login.invalid_credentials') ||
      id.startsWith('ent.ldap.do_login.invalid_password') ||
      id.startsWith('ent.ldap.do_login.user_not_registered')) {
    return const LoginRejected(wrongCredentialsText);
  }
  return LoginRejected(switch (id) {
    'api.context.mfa_required.app_error' => mfaSetupNeededText,
    'api.user.login.inactive.app_error' =>
      "This account is deactivated. Ask the server's admin.",
    'api.user.check_user_login_attempts.too_many.app_error' =>
      'Too many failed attempts locked this account. Reset your password or '
          "ask the server's admin.",
    'api.user.login.not_verified.app_error' =>
      'Verify your email address first, then sign in.',
    _ => connectionProblemText(error, host),
  });
}

/// The site name when no other signed-in server uses it, else the host, so
/// two servers that both call themselves "Mattermost" stay apart.
String defaultDisplayName(String siteName, Uri url, Iterable<String> taken) {
  final name = siteName.trim();
  if (name.isNotEmpty && !taken.contains(name)) return name;
  return url.hasPort ? '${url.host}:${url.port}' : url.host;
}

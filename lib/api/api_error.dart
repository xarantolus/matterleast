import 'dart:io';

import 'package:dio/dio.dart';

/// What went wrong with a request, in terms the rest of the app can act on.
sealed class ApiError implements Exception {
  const ApiError();

  /// [error] as an [ApiError]; anything else (an answer we could not read or
  /// store, say) is an [UnexpectedFailure], never "offline".
  factory ApiError.of(Object error) =>
      error is ApiError ? error : UnexpectedFailure.of(error);

  /// Maps a Dio failure to one of the cases below.
  factory ApiError.from(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      final json = body is Map<String, Object?> ? body : null;
      return ServerError(
        statusCode: response.statusCode ?? 0,
        id: json?['id'] as String?,
        // Plugins built on gin answer `{"error": "..."}`.
        message: switch (json) {
          {'message': final String m} => m,
          {'error': final String m} => m,
          _ => null,
        },
        requestId: json?['request_id'] as String?,
      );
    }
    return switch (e.type) {
      _ when e.error is ApiError => e.error! as ApiError,
      _ when e.error is NoNetwork => const Unreachable(noNetwork: true),
      _ when e.error is ServerDown => const Unreachable(serverDown: true),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const RequestTimeout(),
      DioExceptionType.cancel => const Cancelled(),
      DioExceptionType.badCertificate => const UntrustedCertificate(),
      _ when _refusedHandshake(e.error) => const UntrustedCertificate(),
      _ when e.error is SocketException => const Unreachable(),
      DioExceptionType.connectionError => Unreachable(
        detail: e.error?.runtimeType.toString(),
      ),
      // Lost connections surface as these rather than socket errors.
      _ when e.error is HttpException || e.error is TlsException => Unreachable(
        detail: e.error?.runtimeType.toString(),
      ),
      _ => UnexpectedFailure.of(e.error ?? e),
    };
  }
}

/// A TLS handshake the server's certificate or setup failed, as opposed to
/// one a dropped connection cut short.
bool _refusedHandshake(Object? error) =>
    error is HandshakeException &&
    !error.message.contains('terminated during handshake');

/// The server answered with an error status; [id] is Mattermost's error id,
/// such as `api.user.login.invalid_credentials_email_username`.
final class ServerError extends ApiError {
  const ServerError({
    required this.statusCode,
    this.id,
    this.message,
    this.requestId,
  });

  final int statusCode;
  final String? id;
  final String? message;
  final String? requestId;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ServerError($statusCode, ${id ?? message})';
}

final class RequestTimeout extends ApiError {
  const RequestTimeout();
}

/// No answer arrived. [noNetwork]: the device had no network, so the
/// request was never sent or was stopped when the network went away.
/// [serverDown]: the device has a network but the server is known not to
/// answer right now, so the request was not sent.
final class Unreachable extends ApiError {
  const Unreachable({
    this.detail,
    this.noNetwork = false,
    this.serverDown = false,
  });
  final String? detail;
  final bool noNetwork;
  final bool serverDown;
}

/// Why a request was refused or stopped without a network; [ApiError.from]
/// makes it an [Unreachable].
final class NoNetwork implements Exception {
  const NoNetwork();
}

/// Why a request was refused while its server doesn't answer;
/// [ApiError.from] makes it an [Unreachable].
final class ServerDown implements Exception {
  const ServerDown();
}

final class UntrustedCertificate extends ApiError {
  const UntrustedCertificate();
}

final class Cancelled extends ApiError {
  const Cancelled();
}

/// The system keyring that holds the session token didn't answer (on Linux,
/// no Secret Service running or unlocked), so no request could be signed.
final class KeyringUnavailable extends ApiError {
  const KeyringUnavailable();
}

/// The request reached the server but its answer could not be read or
/// stored. [type] names the error class only, never content.
final class UnexpectedFailure extends ApiError {
  const UnexpectedFailure(this.type);
  UnexpectedFailure.of(Object error) : type = error.runtimeType.toString();
  final String type;

  @override
  String toString() => 'UnexpectedFailure($type)';
}

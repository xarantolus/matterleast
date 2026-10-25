import 'dart:io';

import 'package:dio/dio.dart';

/// What went wrong with a request, in terms the rest of the app can act on.
sealed class ApiError implements Exception {
  const ApiError();

  /// Maps a Dio failure to one of the cases below.
  factory ApiError.from(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      final json = body is Map<String, Object?> ? body : null;
      return ServerError(
        statusCode: response.statusCode ?? 0,
        id: json?['id'] as String?,
        message: json?['message'] as String?,
        requestId: json?['request_id'] as String?,
      );
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const RequestTimeout(),
      DioExceptionType.cancel => const Cancelled(),
      DioExceptionType.badCertificate => const UntrustedCertificate(),
      _ when e.error is SocketException => const Unreachable(),
      _ => Unreachable(detail: e.error?.toString()),
    };
  }
}

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

final class Unreachable extends ApiError {
  const Unreachable({this.detail});
  final String? detail;
}

final class UntrustedCertificate extends ApiError {
  const UntrustedCertificate();
}

final class Cancelled extends ApiError {
  const Cancelled();
}

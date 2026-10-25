import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';

void main() {
  final request = RequestOptions(path: '/api/v4/channels/c1/posts');

  ApiError from(DioExceptionType type, [Object? error]) => ApiError.from(
    DioException(requestOptions: request, type: type, error: error),
  );

  test('only a connection that never got through is unreachable', () {
    expect(
      from(DioExceptionType.unknown, const SocketException('down')),
      isA<Unreachable>(),
    );
    expect(from(DioExceptionType.connectionError), isA<Unreachable>());
    expect(
      from(DioExceptionType.unknown, const HttpException('closed')),
      isA<Unreachable>(),
    );
    expect(from(DioExceptionType.receiveTimeout), isA<RequestTimeout>());
  });

  test('a reply that cannot be read is not offline', () {
    expect(
      from(DioExceptionType.unknown, const FormatException('bad json')),
      isA<UnexpectedFailure>(),
    );
    expect(
      from(DioExceptionType.unknown, TypeError()),
      isA<UnexpectedFailure>(),
    );
    expect(ApiError.of(TypeError()), isA<UnexpectedFailure>());
    expect(ApiError.of(const Unreachable()), isA<Unreachable>());
  });
}

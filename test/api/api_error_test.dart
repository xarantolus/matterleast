import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

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

  group('a certificate or timeout failure is not called offline', () {
    const host = 'chat.example.test';

    test('a refused certificate names the certificate', () {
      final error = from(
        DioExceptionType.unknown,
        const HandshakeException(
          'Handshake error in client',
          OSError('CERTIFICATE_VERIFY_FAILED: unable to get local issuer'),
        ),
      );
      expect(error, isA<UntrustedCertificate>());
      expect(connectionProblemText(error, host), contains('certificate'));
      expect(staleDataNotice(error), "Couldn't update: untrusted certificate");
      expect(
        from(
          DioExceptionType.connectionError,
          const HandshakeException('Handshake error in client'),
        ),
        isA<UntrustedCertificate>(),
      );
    });

    test('a connection dropped during the handshake is still offline', () {
      expect(
        from(
          DioExceptionType.unknown,
          const HandshakeException('Connection terminated during handshake'),
        ),
        isA<Unreachable>(),
      );
    });

    test('a timeout says the server did not answer in time', () {
      const error = RequestTimeout();
      for (final text in [
        connectionProblemText(error, host),
        requestProblemText(TimeoutException('slow'), host),
        staleDataNotice(error),
      ]) {
        expect(text, contains("didn't answer in time"));
        expect(text.toLowerCase(), isNot(contains('offline')));
        expect(text.toLowerCase(), isNot(contains('connection')));
      }
    });

    test("the server's own message is kept", () {
      expect(
        requestProblemText(
          const ServerError(
            statusCode: 403,
            message: 'You do not have the appropriate permissions.',
          ),
          host,
        ),
        '$host said: You do not have the appropriate permissions.',
      );
    });
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

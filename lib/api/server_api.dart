import 'dart:async';

import 'package:dio/dio.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/coalesce.dart';
import 'package:matterleast/api/generated/export.dart';
import 'package:matterleast/api/server_paths.dart';

typedef TokenProvider = FutureOr<String?> Function();

/// One HTTP client per server: base URL, auth header, timeouts, error mapping
/// and coalescing of identical in-flight requests. The generated
/// [MattermostClient] sits on top; nothing above the data layer touches Dio.
class ServerApi {
  ServerApi({
    required this.baseUrl,
    required this._token,
    String? preAuthSecret,
    Duration receiveTimeout = const Duration(seconds: 30),
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: baseUrl.toString(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: receiveTimeout,
      sendTimeout: const Duration(seconds: 30),
      followRedirects: false,
      responseType: ResponseType.json,
      // Dio only implies JSON for maps; id lists would go out as toString().
      contentType: Headers.jsonContentType,
      headers: {'X-Requested-With': 'XMLHttpRequest'},
    );
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (preAuthSecret != null && options.uri.origin == baseUrl.origin) {
            options.headers['X-Mattermost-Preauth-Secret'] = preAuthSecret;
          }
          final token = await _token();
          if (token != null && carriesToken(options.uri, baseUrl)) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          final error = ApiError.from(e);
          if (error is ServerError &&
              error.isUnauthorized &&
              !e.requestOptions.path.endsWith('/users/login')) {
            _sessionEnded.add(null);
          }
          handler.reject(e.copyWith(error: error));
        },
      ),
    );
    client = MattermostClient(this.dio);
  }

  final Uri baseUrl;
  final Dio dio;
  final TokenProvider _token;
  late final MattermostClient client;

  final _inFlight = <String, Future<Object?>>{};
  final _sessionEnded = StreamController<void>.broadcast();

  /// Fires when the server rejects the session token (401 outside login).
  Stream<void> get sessionEnded => _sessionEnded.stream;

  /// The header that signs a request to this server, for players that
  /// fetch on their own.
  Future<Map<String, String>> authHeaders() async {
    final token = await _token();
    return {'Authorization': ?(token == null ? null : 'Bearer $token')};
  }

  /// Runs [request] and turns transport failures into [ApiError]s.
  Future<T> call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      final error = e.error;
      throw error is ApiError ? error : ApiError.from(e);
    }
  }

  /// GETs a JSON object the spec leaves untyped (client config, licence);
  /// null when the answer is not an object.
  Future<Map<String, Object?>?> getJsonObject(
    String path, {
    Map<String, Object?>? query,
  }) async {
    final response = await call(
      () => dio.get<Object?>(path, queryParameters: query),
    );
    final body = response.data;
    return body is Map<String, Object?> ? body : null;
  }

  Future<Map<String, Object?>?> clientConfig() => coalesced(
    'config',
    () => getJsonObject('/api/v4/config/client', query: {'format': 'old'}),
  );

  Future<Map<String, Object?>?> clientLicense() => coalesced(
    'license',
    () => getJsonObject('/api/v4/license/client', query: {'format': 'old'}),
  );

  /// Like [call], but callers asking for the same [key] while a request is
  /// running share its result instead of starting another.
  Future<T> coalesced<T>(String key, Future<T> Function() request) =>
      coalesce<Object?>(
        _inFlight,
        key,
        () => call(request),
      ).then((v) => v as T);

  void close() {
    dio.close(force: true);
    _sessionEnded.close();
  }
}

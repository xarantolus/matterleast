import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/coalesce.dart';
import 'package:matterleast/api/generated/export.dart' show MattermostClient;
import 'package:matterleast/api/server_paths.dart';

typedef TokenProvider = FutureOr<String?> Function();

const _cancelKey = #matterleast.requestCancel;

/// Runs [body] so that every request it makes through a [ServerApi] stops
/// when [cancel] fires, such as a sync job that ran out of time.
Future<T> cancellable<T>(CancelToken cancel, Future<T> Function() body) =>
    runZoned(body, zoneValues: {_cancelKey: cancel});

/// One HTTP client per server: base URL, auth header, deadlines, error
/// mapping and coalescing of identical in-flight requests. The generated
/// [MattermostClient] sits on top; nothing above the data layer touches Dio.
class ServerApi {
  ServerApi({
    required this.baseUrl,
    required this._token,
    String? preAuthSecret,
    this.deadline = defaultDeadline,
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: baseUrl.toString(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
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
          if (Zone.current[_cancelKey] case final CancelToken cancel) {
            final own = options.cancelToken;
            if (own == null) {
              options.cancelToken = cancel;
            } else {
              unawaited(cancel.whenCancel.then((_) => own.cancel()));
            }
          }
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

  /// How long [call] lets a request run in total, unless the call says
  /// otherwise.
  static const defaultDeadline = Duration(seconds: 30);

  /// For file uploads and downloads, which stop on a stall through the
  /// transport timeouts instead.
  static const transferDeadline = Duration(hours: 1);

  final Uri baseUrl;
  final Duration deadline;
  final Dio dio;
  final TokenProvider _token;
  late final MattermostClient client;

  final _inFlight = <String, Future<Object?>>{};
  final _sessionEnded = StreamController<void>.broadcast();

  /// Fires when the server rejects the session token (401 outside login).
  Stream<void> get sessionEnded => _sessionEnded.stream;

  /// Where a player that fetches on its own may stream [url] from, and with
  /// which headers. Players follow redirects themselves and repeat every
  /// header on each hop, so the token goes only with an address that
  /// answers without redirecting; a redirect target is streamed bare.
  Future<({Uri uri, Map<String, String> headers})> streamSource(Uri url) async {
    final cancel = CancelToken();
    final response = await call(
      () => dio.getUri<ResponseBody>(
        url,
        cancelToken: cancel,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: false,
          validateStatus: (_) => true,
          headers: {HttpHeaders.rangeHeader: 'bytes=0-0'},
        ),
      ),
    );
    unawaited(response.data?.stream.drain<void>().catchError((_) {}));
    cancel.cancel();
    final status = response.statusCode ?? 0;
    final location = response.headers.value(HttpHeaders.locationHeader);
    if (status >= 300 && status < 400 && location != null) {
      return (uri: url.resolve(location), headers: const <String, String>{});
    }
    if (status >= 400) throw ServerError(statusCode: status);
    final token = await _token();
    return (
      uri: url,
      headers: {
        if (token != null && carriesToken(url, baseUrl))
          'Authorization': 'Bearer $token',
      },
    );
  }

  /// Runs [request] and turns transport failures into [ApiError]s. The
  /// requests it makes are cancelled after [deadline] (a [RequestTimeout])
  /// or when the surrounding [cancellable] scope is.
  Future<T> call<T>(Future<T> Function() request, {Duration? deadline}) async {
    final cancel = CancelToken();
    if (Zone.current[_cancelKey] case final CancelToken outer) {
      if (outer.isCancelled) throw const Cancelled();
      unawaited(outer.whenCancel.then((_) => cancel.cancel()));
    }
    var late = false;
    final timer = Timer(deadline ?? this.deadline, () {
      late = true;
      cancel.cancel();
    });
    try {
      return await cancellable(cancel, request);
    } on DioException catch (e) {
      if (late) throw const RequestTimeout();
      final error = e.error;
      throw error is ApiError ? error : ApiError.from(e);
    } on Cancelled {
      if (late) throw const RequestTimeout();
      rethrow;
    } finally {
      timer.cancel();
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
  /// running share its result instead of starting another. The shared
  /// request keeps only its deadline, so one caller giving up doesn't stop
  /// it for the others.
  Future<T> coalesced<T>(String key, Future<T> Function() request) =>
      coalesce<Object?>(
        _inFlight,
        key,
        () => runZoned(() => call(request), zoneValues: {_cancelKey: null}),
      ).then((v) => v as T);

  void close() {
    dio.close(force: true);
    _sessionEnded.close();
  }
}

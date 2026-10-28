import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/coalesce.dart';
import 'package:matterleast/api/generated/export.dart' show MattermostClient;
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/api/server_paths.dart';
import 'package:matterleast/api/server_reach.dart';
import 'package:matterleast/api/trusted_authorities.dart';

typedef TokenProvider = FutureOr<String?> Function();

const _cancelKey = #matterleast.requestCancel;
const _probeKey = 'matterleast.probe';

/// Runs [body] so that every request it makes through a [ServerApi] stops
/// when [cancel] fires, such as a sync job that ran out of time.
Future<T> cancellable<T>(CancelToken cancel, Future<T> Function() body) =>
    runZoned(body, zoneValues: {_cancelKey: cancel});

/// One HTTP client per server: base URL, auth header, deadlines, error
/// mapping, and identical GETs in flight sharing one round trip. While
/// [network] reports none nothing is sent, and what is in flight stops when
/// it goes away, so nothing waits for a timeout to say "offline". While
/// [reach] knows the server doesn't answer, each request first waits for a
/// short shared ping and fails at once when it gets none. The generated
/// [MattermostClient] sits on top; nothing above the data layer touches Dio.
class ServerApi {
  ServerApi({
    required this.baseUrl,
    required this._token,
    String? preAuthSecret,
    this.deadline = defaultDeadline,
    this.probeTimeout = defaultProbeTimeout,
    this.probeMemory = ServerReach.defaultProbeMemory,
    this.network,
    Dio? dio,
  }) : dio = dio ?? (Dio()..httpClientAdapter = TrustingAdapter(baseUrl)) {
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
          if (network?.offline ?? false) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: const NoNetwork(),
              ),
              true,
            );
            return;
          }
          if (Zone.current[_cancelKey] case final CancelToken cancel) {
            final own = options.cancelToken;
            if (own == null) {
              options.cancelToken = cancel;
            } else {
              unawaited(cancel.whenCancel.then((e) => own.cancel(e.error)));
            }
          }
          final cancel = options.cancelToken ??= CancelToken();
          if (options.extra[_probeKey] != true && reach.unreachable) {
            final answers = await Future.any([
              reach.probe(),
              cancel.whenCancel.then((_) => true),
            ]);
            // A request stopped meanwhile fails as stopped, below.
            if (!answers && !cancel.isCancelled) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  error: const ServerDown(),
                ),
                true,
              );
              return;
            }
          }
          if (preAuthSecret != null && options.uri.origin == baseUrl.origin) {
            options.headers['X-Mattermost-Preauth-Secret'] = preAuthSecret;
          }
          final String? token;
          try {
            token = await _token();
          } on ApiError catch (e) {
            handler.reject(DioException(requestOptions: options, error: e));
            return;
          }
          if (token != null && carriesToken(options.uri, baseUrl)) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _live.add(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _live.remove(response.requestOptions);
          reach.answered();
          handler.next(response);
        },
        onError: (e, handler) {
          _live.remove(e.requestOptions);
          if (e.response != null) {
            reach.answered();
          } else if (_noAnswer(e)) {
            reach.noAnswer();
          }
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
    this.dio.httpClientAdapter = _SameGets(this.dio.httpClientAdapter);
    client = MattermostClient(this.dio);
    network?.online.addListener(_networkChanged);
    reach.reachable.addListener(_reachChanged);
  }

  /// The transport gave up waiting for the server.
  static bool _noAnswer(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;

  /// How long a ping may take while the server is believed down; a server
  /// that answers more slowly counts as down until a request gets through.
  static const defaultProbeTimeout = Duration(seconds: 4);
  final Duration probeTimeout;

  /// How long a failed ping stands for.
  final Duration probeMemory;

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
  final NetworkState? network;
  late final MattermostClient client;

  /// Whether this server answers, from what its requests and its socket
  /// saw.
  late final reach = ServerReach(ping: _ping, probeMemory: probeMemory);

  /// Requests between being sent and their answer (or failure).
  final _live = Set<RequestOptions>.identity();

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
    var outOfTime = false;
    if (Zone.current[_cancelKey] case final CancelToken outer) {
      if (outer.isCancelled) throw const Cancelled();
      unawaited(
        outer.whenCancel.then((e) {
          outOfTime = e.error is RequestTimeout;
          cancel.cancel(e.error);
        }),
      );
    }
    var late = false;
    final timer = Timer(deadline ?? this.deadline, () {
      late = true;
      cancel.cancel(const RequestTimeout());
    });
    final started = DateTime.now();
    try {
      return await cancellable(cancel, request);
    } on Object catch (e) {
      // Stopped for taking too long, after more than a connection may
      // take; an impatient caller doesn't make a slow server look down.
      if ((late || outOfTime) &&
          DateTime.now().difference(started) >=
              (dio.options.connectTimeout ?? Duration.zero)) {
        reach.noAnswer();
      }
      if (late) throw const RequestTimeout();
      if (e is DioException) {
        final error = e.error;
        throw error is ApiError ? error : ApiError.from(e);
      }
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

  Future<Map<String, Object?>?> clientConfig() =>
      getJsonObject('/api/v4/config/client', query: {'format': 'old'});

  Future<Map<String, Object?>?> clientLicense() =>
      getJsonObject('/api/v4/license/client', query: {'format': 'old'});

  /// Like [call], for work that is more than one GET (a search, which is a
  /// POST, or fetches with their store writes): callers asking for the
  /// same [key] while it runs share its result. The shared work keeps only
  /// its deadline, so one caller giving up doesn't stop it for the others.
  Future<T> coalesced<T>(String key, Future<T> Function() request) =>
      coalesce<Object?>(
        _inFlight,
        key,
        () => runZoned(() => call(request), zoneValues: {_cancelKey: null}),
      ).then((v) => v as T);

  /// One short `system/ping`: any answer, even an error, means the server
  /// is there.
  Future<bool> _ping() async {
    try {
      // Shared by every waiting request, so none of them may cancel it.
      await runZoned(
        () => call(
          () => dio.get<Object?>(
            '/api/v4/system/ping',
            options: Options(extra: {_probeKey: true}),
          ),
          deadline: probeTimeout,
        ),
        zoneValues: {_cancelKey: null},
      );
      return true;
    } on ServerError {
      return true;
    } on ApiError {
      return false;
    }
  }

  void _networkChanged() {
    if (!network!.offline) return;
    for (final options in _live.toList()) {
      options.cancelToken?.cancel(const NoNetwork());
    }
  }

  /// Requests waiting on a server just found not to answer stop now
  /// instead of at their timeouts.
  void _reachChanged() {
    if (!reach.unreachable) return;
    for (final options in _live.toList()) {
      if (options.extra[_probeKey] == true) continue;
      options.cancelToken?.cancel(const ServerDown());
    }
  }

  void close() {
    reach.reachable.removeListener(_reachChanged);
    network?.online.removeListener(_networkChanged);
    reach.dispose();
    dio.close(force: true);
    _sessionEnded.close();
  }
}

/// Joins identical GETs (same address, query and response type) while one
/// is in flight: the bytes of one answer go to every caller, and each
/// decodes its own copy. A caller that joined and gives up leaves the
/// request running for the others; when the request it joined is
/// cancelled, it sends its own.
class _SameGets implements HttpClientAdapter {
  _SameGets(this._inner);

  final HttpClientAdapter _inner;
  final _running = <String, Future<_Answer>>{};

  static String? _keyOf(RequestOptions options) =>
      options.method.toUpperCase() == 'GET' &&
          (options.responseType == ResponseType.json ||
              options.responseType == ResponseType.plain)
      ? '${options.responseType.name} ${options.uri}'
      : null;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = _keyOf(options);
    if (key == null) return _inner.fetch(options, requestStream, cancelFuture);
    for (
      var running = _running[key];
      running != null;
      running = _running[key]
    ) {
      try {
        return (await running).body();
      } on _GaveUp {
        continue;
      } on DioException catch (e) {
        throw e.copyWith(requestOptions: options);
      }
    }
    final done = Completer<_Answer>();
    // Nobody may have joined; the failure reaches this caller below.
    unawaited(done.future.then((_) {}, onError: (Object _) {}));
    _running[key] = done.future;
    void settled() {
      if (identical(_running[key], done.future)) _running.remove(key);
    }

    var gaveUp = false;
    unawaited(cancelFuture?.then((_) => gaveUp = true));
    try {
      final body = await _inner.fetch(options, requestStream, cancelFuture);
      final bytes = BytesBuilder(copy: false);
      await body.stream.forEach(bytes.add);
      final answer = (
        bytes: bytes.takeBytes(),
        statusCode: body.statusCode,
        statusMessage: body.statusMessage,
        headers: body.headers,
        isRedirect: body.isRedirect,
        redirects: body.redirects,
        extra: body.extra,
      );
      settled();
      done.complete(answer);
      return answer.body();
    } catch (e, s) {
      settled();
      done.completeError(gaveUp ? const _GaveUp() : e, s);
      rethrow;
    }
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);
}

/// The caller whose request others joined gave up on it.
class _GaveUp implements Exception {
  const _GaveUp();
}

typedef _Answer = ({
  Uint8List bytes,
  int statusCode,
  String? statusMessage,
  Map<String, List<String>> headers,
  bool isRedirect,
  List<RedirectRecord>? redirects,
  Map<String, dynamic> extra,
});

extension on _Answer {
  ResponseBody body() => ResponseBody(
    Stream.value(bytes),
    statusCode,
    statusMessage: statusMessage,
    headers: {
      for (final e in headers.entries) e.key: [...e.value],
    },
    isRedirect: isRedirect,
    redirects: redirects,
  )..extra = {...extra};
}

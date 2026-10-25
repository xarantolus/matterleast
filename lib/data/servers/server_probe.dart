import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/domain/login_options.dart';
import 'package:matterleast/domain/server_url.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

/// A Mattermost server found at an address, with what it offers for login.
@immutable
class ProbedServer {
  const ProbedServer({
    required this.url,
    required this.options,
    required this.config,
    required this.license,
  });

  final Uri url;
  final LoginOptions options;

  /// The client config and licence as served, stored in the server database
  /// after login.
  final Map<String, Object?> config;
  final Map<String, Object?> license;

  bool get versionSupported => isServerVersionSupported(options.serverVersion);
}

class ProbeFailure implements Exception {
  const ProbeFailure(this.message);
  final String message;

  @override
  String toString() => 'ProbeFailure($message)';
}

const _pingPath = '/api/v4/system/ping';

/// Checks that an address is a Mattermost server and reads its login options.
/// Nothing is stored and no token is sent.
class ServerProbe {
  ServerProbe({
    this.allowHttp = kDebugMode,
    this.timeout = const Duration(seconds: 15),
  });

  /// Plain http only in debug builds, for the local test server.
  final bool allowHttp;
  final Duration timeout;

  Future<ProbedServer> probe(String typed) async {
    final typedUrl = normalizeServerUrl(typed);
    if (typedUrl == null) throw const ProbeFailure(invalidAddressText);
    if (typedUrl.scheme == 'http' && !allowHttp) {
      throw const ProbeFailure(httpNotAllowedText);
    }
    final url = await _ping(typedUrl);
    final api = _api(url);
    try {
      final config = await _getMap(api, '/api/v4/config/client');
      final license = await _getMap(api, '/api/v4/license/client');
      final options = loginOptionsFrom(config, license);
      if (options.diagnosticId.isEmpty) {
        throw const ProbeFailure(notMattermostText);
      }
      return ProbedServer(
        url: url,
        options: options,
        config: config,
        license: license,
      );
    } on ApiError catch (e) {
      throw ProbeFailure(probeProblemText(e, url.authority));
    } finally {
      api.close();
    }
  }

  ServerApi _api(Uri url) =>
      ServerApi(baseUrl: url, token: () => null, receiveTimeout: timeout);

  /// Pings the server, following redirects (e.g. a bare domain that moved to
  /// a sub-path), and returns the base URL that answered.
  Future<Uri> _ping(Uri url) async {
    final api = _api(url);
    try {
      final response = await api.call(
        () => api.dio.get<Object?>(
          _pingPath,
          options: Options(followRedirects: true, maxRedirects: 5),
        ),
      );
      final body = response.data;
      // A relative Location header leaves realUri relative too.
      final base = baseUrlFromPing(
        response.requestOptions.uri.resolveUri(response.realUri),
      );
      if (body is! Map || body['status'] != 'OK' || base == null) {
        throw const ProbeFailure(notMattermostText);
      }
      if (url.scheme == 'https' && base.scheme != 'https') {
        throw ProbeFailure(
          '${url.authority} redirected to a plain http:// address, so the app '
          "didn't connect.",
        );
      }
      return base;
    } on ApiError catch (e) {
      throw ProbeFailure(probeProblemText(e, url.authority));
    } finally {
      api.close();
    }
  }

  Future<Map<String, Object?>> _getMap(ServerApi api, String path) async {
    final response = await api.call(
      () => api.dio.get<Object?>(path, queryParameters: {'format': 'old'}),
    );
    final body = response.data;
    if (body is! Map<String, Object?>) {
      throw const ProbeFailure(notMattermostText);
    }
    return body;
  }
}

/// The server root of a ping URL that answered, or null when the answer came
/// from somewhere that is not a ping endpoint.
Uri? baseUrlFromPing(Uri pingUrl) {
  final path = pingUrl.path;
  if (!path.endsWith(_pingPath)) return null;
  return Uri(
    scheme: pingUrl.scheme,
    host: pingUrl.host,
    port: pingUrl.hasPort ? pingUrl.port : null,
    path: path.substring(0, path.length - _pingPath.length),
  );
}

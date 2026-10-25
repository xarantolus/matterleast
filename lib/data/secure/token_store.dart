import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session tokens, one per server URL, in Keystore-backed encrypted storage.
/// Nothing else in the app reads or writes them.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
          );

  final FlutterSecureStorage _storage;
  final _cache = <String, String?>{};

  String _key(String serverUrl) => 'token:$serverUrl';

  /// The token for [serverUrl], or null when logged out. Cached after the
  /// first read so the request path never waits on the Keystore.
  Future<String?> read(String serverUrl) async {
    if (_cache.containsKey(serverUrl)) return _cache[serverUrl];
    final value = await _storage.read(key: _key(serverUrl));
    _cache[serverUrl] = value;
    return value;
  }

  /// The cached token, if [read] or [write] already ran for this server.
  String? cached(String serverUrl) => _cache[serverUrl];

  Future<void> write(String serverUrl, String token) async {
    _cache[serverUrl] = token;
    await _storage.write(key: _key(serverUrl), value: token);
  }

  Future<void> delete(String serverUrl) async {
    _cache[serverUrl] = null;
    await _storage.delete(key: _key(serverUrl));
  }
}

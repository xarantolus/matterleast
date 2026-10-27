import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/log.dart';

/// Session tokens, one per server URL, in the platform's encrypted storage
/// (Keystore, Credential Manager, the Secret Service keyring). Nothing else
/// in the app reads or writes them.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
          );

  final FlutterSecureStorage _storage;
  final _cache = <String, String?>{};
  final _unavailableChanges = StreamController<bool>.broadcast();
  var _unavailable = false;
  var _busy = Future<void>.value();

  String _key(String serverUrl) => 'token:$serverUrl';

  /// The storage didn't answer, and reads fail at once with
  /// [KeyringUnavailable] until [retry]. A locked Linux keyring asks for its
  /// password on each access and holds the app's platform thread meanwhile,
  /// so a burst of requests must not ask it once each.
  bool get unavailable => _unavailable;
  Stream<bool> get unavailableChanges => _unavailableChanges.stream;

  /// Lets the next read ask the storage again.
  void retry() => _setUnavailable(false);

  /// The token for [serverUrl], or null when logged out. Cached after the
  /// first read so the request path never waits on the Keystore.
  Future<String?> read(String serverUrl) async {
    if (_cache.containsKey(serverUrl)) return _cache[serverUrl];
    final value = await _serial(() async {
      if (_cache.containsKey(serverUrl)) return _cache[serverUrl];
      if (_unavailable) throw const KeyringUnavailable();
      return _storage.read(key: _key(serverUrl));
    });
    _cache[serverUrl] = value;
    return value;
  }

  /// The cached token, if [read] or [write] already ran for this server.
  String? cached(String serverUrl) => _cache[serverUrl];

  /// Asks the storage even after it failed, since the user is signing in.
  Future<void> write(String serverUrl, String token) async {
    await _serial(() => _storage.write(key: _key(serverUrl), value: token));
    _cache[serverUrl] = token;
  }

  /// Signing out goes on without the storage; the stale token there is
  /// replaced by the next sign-in.
  Future<void> delete(String serverUrl) async {
    _cache[serverUrl] = null;
    if (_unavailable) return;
    try {
      await _serial(() => _storage.delete(key: _key(serverUrl)));
    } on KeyringUnavailable {
      Log.warn('servers', 'The keyring is unavailable; token not deleted');
    }
  }

  /// One storage call at a time.
  Future<T> _serial<T>(Future<T> Function() call) {
    final result = _busy.then((_) async {
      try {
        final value = await call();
        _setUnavailable(false);
        return value;
      } on PlatformException {
        _setUnavailable(true);
        throw const KeyringUnavailable();
      }
    });
    _busy = result.then((_) {}, onError: (Object _) {});
    return result;
  }

  void _setUnavailable(bool unavailable) {
    if (unavailable == _unavailable) return;
    _unavailable = unavailable;
    _unavailableChanges.add(unavailable);
  }
}

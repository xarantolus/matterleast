import 'dart:convert';

import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/domain/pending_sso.dart';
import 'package:matterleast/log.dart';

/// The one browser sign-in that may be waiting for its callback, kept in the
/// encrypted storage until it ends.
class PendingSsoStore {
  PendingSsoStore(this._tokens);

  final TokenStore _tokens;

  /// Without a working storage the sign-in still goes on; only finishing it
  /// after a restart is lost.
  Future<void> save(PendingSso pending) =>
      _guarded(() => _tokens.writePendingSso(jsonEncode(pending.toJson())));

  Future<void> clear() => _guarded(_tokens.deletePendingSso);

  Future<void> _guarded(Future<void> Function() call) async {
    try {
      await call();
    } on KeyringUnavailable {
      Log.warn('sso', 'The keyring is unavailable; pending sign-in not kept');
    }
  }

  /// The saved sign-in; one that doesn't parse is dropped.
  Future<PendingSso?> load() async {
    final String? raw;
    try {
      raw = await _tokens.readPendingSso();
    } on KeyringUnavailable {
      return null;
    }
    if (raw == null) return null;
    try {
      if (jsonDecode(raw) case final Map<String, Object?> json) {
        return PendingSso.fromJson(json);
      }
    } on Object {
      // Dropped below.
    }
    Log.warn('sso', 'Dropped an unreadable pending sign-in');
    await clear();
    return null;
  }
}

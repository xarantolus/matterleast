import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/server_url.dart';
import 'package:matterleast/log.dart';
import 'package:path/path.dart' as p;

typedef OpenServerDatabase = ServerDatabase Function(String path);

/// Adds, signs out and removes servers, and owns the open [ServerSession]s.
/// A server is signed in while its row has `lastActiveAt` set; signing out
/// deletes its token and database and keeps the row for a quick sign-in.
class ServerManager {
  ServerManager({
    required this._db,
    required this._tokens,
    required this._dataDirectory,
    required this._cacheDirectory,
    this._mediaBudget = _defaultMediaBudget,
    this._openDatabase = ServerDatabase.open,
    this._clock = DateTime.now,
  });

  final AppDatabase _db;
  final TokenStore _tokens;
  final Future<String> Function() _dataDirectory;
  final Future<String> Function() _cacheDirectory;
  final Future<int> Function() _mediaBudget;
  final OpenServerDatabase _openDatabase;
  final DateTime Function() _clock;

  static Future<int> _defaultMediaBudget() async => 250 * 1024 * 1024;

  final _sessions = <String, Future<ServerSession>>{};
  final _subscriptions = <String, StreamSubscription<void>>{};

  /// Servers being signed out on purpose; their 401s are not a notice.
  final _leaving = <String>{};
  final _sessionEnded = StreamController<ServerRow>.broadcast();
  final _changed = StreamController<String>.broadcast();

  /// A server that rejected its token outside of a sign-in. Its data is
  /// already gone when this fires.
  Stream<ServerRow> get sessionEnded => _sessionEnded.stream;

  /// URLs whose session was closed or replaced by a new sign-in; holders of
  /// a session look it up again.
  Stream<String> get changed => _changed.stream;

  /// Signs out servers whose token went missing (e.g. Keystore reset), so the
  /// list never shows a server as signed in that can't be used.
  Future<void> checkTokens() async {
    for (final server in await _db.allServers()) {
      if (server.lastActiveAt == null) continue;
      if (await _tokens.read(server.url) == null) {
        Log.warn('servers', 'No token for a signed-in server; signing out');
        await _wipe(server.url);
      }
    }
  }

  var _foreground = false;

  static const stagger = Duration(seconds: 5);

  /// The app was shown or hidden. Signed-in servers connect while it is
  /// shown, the most recently used first and the others 5 s apart, and go
  /// quiet a little after it is hidden. Connecting also refreshes each
  /// server's data, which is how a session revoked meanwhile is noticed.
  Future<void> setForeground(bool foreground) async {
    _foreground = foreground;
    if (!foreground) {
      for (final pending in _sessions.values.toList()) {
        (await pending).connection.background();
      }
      return;
    }
    final signedIn = [
      for (final s in await _db.allServers())
        if (s.lastActiveAt != null) s,
    ]..sort((a, b) => b.lastActiveAt!.compareTo(a.lastActiveAt!));
    for (final (i, server) in signedIn.indexed) {
      if (!_foreground) return;
      final ServerSession session;
      try {
        session = await this.session(server.url);
      } on Object catch (e) {
        Log.warn('servers', 'Opening a server failed', e);
        continue;
      }
      session.connection.foreground(delay: stagger * i);
    }
  }

  /// The open session of a signed-in server, opened on first use.
  Future<ServerSession> session(String url) =>
      _sessions[url] ??= _open(url).catchError((Object e) {
        _sessions.remove(url);
        throw e;
      });

  Future<ServerSession> _open(String url) async {
    final row = await _db.serverByUrl(url);
    if (row == null || row.lastActiveAt == null) {
      throw StateError('Not signed in to this server');
    }
    final path = p.join(await _dataDirectory(), row.dbFile);
    final session = ServerSession.open(
      url: Uri.parse(url),
      db: _openDatabase(path),
      dbPath: path,
      imagesDirectory: await _imagesDirectory(row.dbFile),
      mediaBudget: _mediaBudget,
      tokens: _tokens,
    );
    _subscriptions[url] = session.api.sessionEnded.listen(
      (_) => _onSessionEnded(url),
    );
    return session;
  }

  /// Stores a fresh sign-in: token, server row and the first data in the
  /// server's own database. A row for the same server under another URL is
  /// replaced.
  Future<void> addSignedIn({
    required ProbedServer server,
    required String displayName,
    required SignedIn signedIn,
    String? ssoScheme,
  }) async {
    final url = server.url.toString();
    final previous = await _db.serverByDiagnosticId(
      server.options.diagnosticId,
    );
    if (previous != null && previous.url != url) {
      await remove(previous.url, force: true);
    }
    await _closeSession(url);
    final existing = await _db.serverByUrl(url);
    final now = _clock();
    await _tokens.write(url, signedIn.token);
    await _db.upsertServer(
      ServersCompanion.insert(
        url: url,
        displayName: displayName,
        dbFile: serverDbFileName(server.url),
        diagnosticId: Value(server.options.diagnosticId),
        serverVersion: Value(server.options.serverVersion),
        siteName: Value(server.options.siteName),
        sortOrder: Value(existing?.sortOrder ?? await _nextSortOrder()),
        addedAt: existing?.addedAt ?? now,
        lastActiveAt: Value(now),
        ssoScheme: Value(ssoScheme ?? existing?.ssoScheme),
      ),
    );
    final session = await this.session(url);
    _changed.add(url);
    await session.store.applyMe(signedIn.me);
    await session.store.applyConfig('client_config', server.config);
    await session.store.applyConfig('license', server.license);
    if (_foreground) session.connection.foreground();
  }

  Future<int> _nextSortOrder() async {
    final all = await _db.allServers();
    return all.isEmpty
        ? 0
        : all.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Marks [url] as the server the user is looking at.
  Future<void> markActive(String url) async {
    final row = await _db.serverByUrl(url);
    if (row == null || row.lastActiveAt == null) return;
    await _db.upsertServer(
      row.toCompanion(false).copyWith(lastActiveAt: Value(_clock())),
    );
  }

  /// Ends the session on the server, then wipes it here. Returns false when
  /// the server couldn't be told; call again with [force] to sign out anyway.
  Future<bool> signOut(String url, {bool force = false}) async {
    if (!force && !await _tellServer(url)) return false;
    await _wipe(url);
    return true;
  }

  /// Signs out (see [signOut]) and forgets the server.
  Future<bool> remove(String url, {bool force = false}) async {
    final row = await _db.serverByUrl(url);
    if (row == null) return true;
    if (row.lastActiveAt != null && !force && !await _tellServer(url)) {
      return false;
    }
    await _wipe(url);
    await _db.deleteServer(url);
    return true;
  }

  Future<bool> _tellServer(String url) async {
    _leaving.add(url);
    try {
      final session = await this.session(url);
      await session.api.call(() => session.api.client.users.logout());
      return true;
    } on ServerError catch (e) {
      // The session is already gone on the server.
      return e.isUnauthorized;
    } on ApiError {
      return false;
    } finally {
      _leaving.remove(url);
    }
  }

  Future<void> _onSessionEnded(String url) async {
    if (_leaving.contains(url)) return;
    _leaving.add(url);
    try {
      Log.info('servers', 'Session ended by the server');
      await _wipe(url);
      final row = await _db.serverByUrl(url);
      if (row != null) _sessionEnded.add(row);
    } finally {
      _leaving.remove(url);
    }
  }

  /// Closes the session and deletes everything stored for [url] except its
  /// row, which stays as signed out. The row is marked first, so nothing
  /// that reacts to the closed session can open the database again.
  Future<void> _wipe(String url) async {
    final row = await _db.serverByUrl(url);
    if (row != null) {
      await _db.upsertServer(
        row.toCompanion(false).copyWith(lastActiveAt: const Value(null)),
      );
    }
    await _closeSession(url);
    await _tokens.delete(url);
    if (row != null) {
      await _deleteDatabaseFiles(row.dbFile);
      final images = Directory(await _imagesDirectory(row.dbFile));
      if (images.existsSync()) await images.delete(recursive: true);
    }
  }

  /// Image caches sit next to nothing else, in a folder named like the
  /// server's database file.
  Future<String> _imagesDirectory(String dbFile) async =>
      p.join(await _cacheDirectory(), p.basenameWithoutExtension(dbFile));

  Future<void> _closeSession(String url) async {
    final pending = _sessions.remove(url);
    await _subscriptions.remove(url)?.cancel();
    if (pending == null) return;
    try {
      await (await pending).close();
    } on Object catch (e) {
      Log.warn('servers', 'Closing a session failed', e);
    }
    _changed.add(url);
  }

  Future<void> _deleteDatabaseFiles(String fileName) async {
    final base = p.join(await _dataDirectory(), fileName);
    for (final suffix in const ['', '-wal', '-shm', '-journal']) {
      final file = File('$base$suffix');
      if (file.existsSync()) await file.delete();
    }
  }

  Future<void> dispose() async {
    for (final url in _sessions.keys.toList()) {
      await _closeSession(url);
    }
    await _sessionEnded.close();
    await _changed.close();
  }
}

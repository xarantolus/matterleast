import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';

/// Fetches people the database doesn't have yet, by id or by username.
/// Requests arriving within [window] are asked together in chunks of
/// [chunkSize], and a person already being fetched is not asked for again.
class UserLoader {
  UserLoader({
    required this.server,
    required this.store,
    this.window = const Duration(milliseconds: 20),
  }) {
    _byId = _Batches(window, (ids) => _load(ids, byUsername: false));
    _byUsername = _Batches(window, (names) => _load(names, byUsername: true));
  }

  final ServerApi server;
  final ServerStore store;
  final Duration window;

  static const chunkSize = 100;

  late final _Batches _byId;
  late final _Batches _byUsername;

  ServerDatabase get _db => store.db;

  /// Completes once everyone in [ids] is stored, or the server said they
  /// don't exist. Throws what the server answered when it couldn't be
  /// asked.
  Future<void> ensure(Iterable<String> ids) => _byId.add({
    for (final id in ids)
      if (id.isNotEmpty) id,
  });

  /// As [ensure], by usernames, such as from mentions.
  Future<void> ensureUsernames(Iterable<String> usernames) => _byUsername.add({
    for (final name in usernames)
      if (name.isNotEmpty) name.toLowerCase(),
  });

  Future<void> _load(List<String> keys, {required bool byUsername}) async {
    final column = byUsername ? _db.users.username : _db.users.id;
    final query = _db.selectOnly(_db.users)
      ..addColumns([column])
      ..where(column.isIn(keys));
    final known = {for (final row in await query.get()) row.read(column)};
    final missing = [
      for (final key in keys)
        if (!known.contains(key)) key,
    ];
    for (var i = 0; i < missing.length; i += chunkSize) {
      final chunk = missing.sublist(
        i,
        (i + chunkSize).clamp(0, missing.length),
      );
      final List<api.User> users = await server.call(
        () => byUsername
            ? server.client.users.getUsersByUsernames(body: chunk)
            : server.client.users.getUsersByIds(body: chunk),
      );
      await store.applyUsers(users);
    }
  }

  void close() {
    _byId.close();
    _byUsername.close();
  }
}

/// Keys collected for [window], then handed to [load] at once; a key
/// already on its way waits for that load instead.
class _Batches {
  _Batches(this.window, this.load);

  final Duration window;
  final Future<void> Function(List<String> keys) load;

  final _queued = <String>{};
  final _waiting = <String, Future<void>>{};
  Completer<void>? _next;
  Timer? _timer;

  Future<void> add(Set<String> keys) {
    final waits = <Future<void>>{};
    for (final key in keys) {
      final pending = _waiting[key];
      if (pending != null) {
        waits.add(pending);
        continue;
      }
      final next = _next ??= Completer<void>()..future.ignore();
      _queued.add(key);
      _waiting[key] = next.future;
      waits.add(next.future);
    }
    if (_queued.isNotEmpty) {
      _timer ??= Timer(window, () => unawaited(_flush()));
    }
    return Future.wait(waits);
  }

  Future<void> _flush() async {
    _timer = null;
    final keys = _queued.toList();
    final done = _next!;
    _queued.clear();
    _next = null;
    try {
      await load(keys);
      done.complete();
    } on Object catch (e, stack) {
      done.completeError(e, stack);
    } finally {
      _waiting.removeWhere((_, waiting) => identical(waiting, done.future));
    }
  }

  void close() {
    _timer?.cancel();
    _timer = null;
    _next?.completeError(StateError('closed'));
    _next = null;
    _queued.clear();
    _waiting.clear();
  }
}

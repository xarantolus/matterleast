import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/log.dart';

/// The server's custom emoji as name → id, from the `custom_emoji` table.
Stream<Map<String, String>> watchCustomEmoji(ServerStore store) {
  final db = store.db;
  return throttledWatch(
    db.tableUpdates(TableUpdateQuery.onAllTables([db.customEmoji])),
    () async => {
      for (final row in await db.select(db.customEmoji).get()) row.name: row.id,
    },
    interval: const Duration(milliseconds: 300),
  ).distinct(_sameMap);
}

/// The creator id of custom emoji [name], once stored.
Stream<String?> watchEmojiCreator(ServerStore store, String name) {
  final db = store.db;
  return (db.select(db.customEmoji)..where((e) => e.name.equals(name)))
      .watch()
      .map((rows) => rows.firstOrNull?.creatorId)
      .distinct();
}

bool _sameMap(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

final _validName = RegExp(r'^[a-z0-9_+-]{1,64}$');

/// Looks up custom emoji names that text uses but the database doesn't
/// know yet. Callers report such names with [want]; they are collected for
/// a moment and asked for in batches, and what the server knows lands in
/// `custom_emoji`, where [watchCustomEmoji] picks it up. Names the server
/// doesn't know are not asked for again for an hour; [missing] lists them
/// so they can be drawn as their names instead of waiting for an image.
class CustomEmojiResolver {
  CustomEmojiResolver({
    required this.server,
    required this.store,
    this.debounce = const Duration(milliseconds: 200),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ServerApi server;
  final ServerStore store;
  final Duration debounce;
  final DateTime Function() _clock;

  static const batchSize = 200;
  static const unknownFor = Duration(hours: 1);
  static const failedFor = Duration(minutes: 1);

  final _pending = <String>{};
  final _asking = <String>{};

  /// Names not to ask for again before the time they map to.
  final _quietUntil = <String, DateTime>{};
  final _missingChanges = StreamController<Set<String>>.broadcast();
  Timer? _timer;
  Future<void>? _running;
  var _byNamesMissing = false;
  var _closed = false;

  /// Reports names that could not be resolved locally. Unicode emoji names
  /// and names already being looked up are skipped.
  void want(Iterable<String> names) {
    if (_closed) return;
    final now = _clock();
    for (final name in names) {
      if (!_validName.hasMatch(name) || isKnownEmoji(name)) continue;
      if (_asking.contains(name)) continue;
      final quiet = _quietUntil[name];
      if (quiet != null && now.isBefore(quiet)) continue;
      _pending.add(name);
    }
    if (_pending.isNotEmpty) _timer ??= Timer(debounce, _flush);
  }

  /// Names the last lookups found no custom emoji for, or couldn't ask
  /// about.
  Set<String> get missing {
    final now = _clock();
    return {
      for (final MapEntry(key: name, value: until) in _quietUntil.entries)
        if (now.isBefore(until)) name,
    };
  }

  /// [missing] each time it changes.
  Stream<Set<String>> get missingChanges => _missingChanges.stream;

  /// Completes once the lookups started so far have landed; for tests and
  /// callers that need the answer before going on.
  Future<void> get settled async {
    while (_timer != null || _running != null) {
      if (_timer != null) {
        _timer!.cancel();
        _flush();
      }
      await _running;
    }
  }

  void _flush() {
    _timer = null;
    final names = _pending.toList();
    _pending.clear();
    if (names.isEmpty || _closed) return;
    _asking.addAll(names);
    final previous = _running ?? Future<void>.value();
    late final Future<void> run;
    run = previous
        .then((_) => _resolve(names))
        .catchError((Object e) {
          Log.warn('emoji', 'Resolving custom emoji failed', e);
        })
        .whenComplete(() {
          _asking.removeAll(names);
          if (identical(_running, run)) _running = null;
        });
    _running = run;
  }

  Future<void> _resolve(List<String> names) async {
    if (!(await store.db.features()).customEmoji) {
      _quiet(names, unknownFor);
      return;
    }
    final stored = {
      for (final row in await (store.db.select(
        store.db.customEmoji,
      )..where((e) => e.name.isIn(names))).get())
        row.name,
    };
    final missing = [
      for (final n in names)
        if (!stored.contains(n)) n,
    ];
    for (var i = 0; i < missing.length; i += batchSize) {
      if (_closed) return;
      final batch = missing.sublist(
        i,
        i + batchSize > missing.length ? missing.length : i + batchSize,
      );
      await _lookUp(batch);
    }
  }

  Future<void> _lookUp(List<String> names) async {
    final List<api.Emoji> found;
    try {
      found = await _find(names);
    } on ApiError catch (e) {
      if (endpointUnavailable(e)) {
        await store.turnOff(OptionalFeature.customEmoji);
        return;
      }
      _quiet(names, failedFor);
      Log.warn('emoji', 'Looking up custom emoji failed', e);
      return;
    }
    if (_closed) return;
    await store.applyCustomEmoji(found);
    final known = {for (final e in found) ?e.name};
    _quiet([
      for (final n in names)
        if (!known.contains(n)) n,
    ], unknownFor);
  }

  Future<List<api.Emoji>> _find(List<String> names) async {
    if (!_byNamesMissing) {
      try {
        return await _byNames(names);
      } on ServerError catch (e) {
        if (!_isAbsent(e)) rethrow;
        // Servers before 9.2 have no batch lookup.
        _byNamesMissing = true;
      }
    }
    return _oneByOne(names);
  }

  static bool _isAbsent(ServerError e) =>
      e.statusCode == 404 || e.statusCode == 501;

  void _quiet(Iterable<String> names, Duration span) {
    final until = _clock().add(span);
    for (final n in names) {
      _quietUntil[n] = until;
    }
    if (names.isNotEmpty && !_closed) _missingChanges.add(missing);
  }

  Future<List<api.Emoji>> _byNames(List<String> names) async {
    final response = await server.call(
      () => server.dio.post<List<Object?>>(
        '/api/v4/emoji/names',
        data: names,
        options: Options(responseType: ResponseType.json),
      ),
    );
    return [
      for (final item in response.data ?? const <Object?>[])
        if (item is Map<String, Object?>) api.Emoji.fromJson(item),
    ];
  }

  Future<List<api.Emoji>> _oneByOne(List<String> names) async {
    final found = <api.Emoji>[];
    for (final name in names) {
      try {
        found.add(
          await server.call(
            () => server.client.emoji.getEmojiByName(emojiName: name),
          ),
        );
      } on ServerError catch (e) {
        // 501 is the whole feature switched off, not one unknown name.
        if (!_isAbsent(e) || endpointUnavailable(e)) rethrow;
      }
    }
    return found;
  }

  Future<void>? _catalog;

  /// Stores every custom emoji of the server, a page at a time, for the
  /// picker. Runs once per session; a failed run is tried again on the next
  /// call.
  Future<void> loadAll() => _catalog ??= _loadAll().catchError((Object e) {
    _catalog = null;
    Log.warn('emoji', 'Loading the custom emoji failed', e);
  });

  static const catalogPageSize = 200;

  Future<void> _loadAll() async {
    if (!(await store.db.features()).customEmoji) return;
    for (var page = 0; !_closed; page++) {
      final List<Object?> items;
      try {
        final response = await server.call(
          () => server.dio.get<List<Object?>>(
            '/api/v4/emoji',
            queryParameters: {
              'page': page,
              'per_page': catalogPageSize,
              'sort': 'name',
            },
            options: Options(responseType: ResponseType.json),
          ),
        );
        items = response.data ?? const [];
      } on ApiError catch (e) {
        if (endpointUnavailable(e)) {
          await store.turnOff(OptionalFeature.customEmoji);
          return;
        }
        rethrow;
      }
      if (_closed) return;
      await store.applyCustomEmoji([
        for (final item in items)
          if (item is Map<String, Object?>)
            ?decodeOrSkip(item, api.Emoji.fromJson),
      ]);
      if (items.length < catalogPageSize) return;
    }
  }

  void close() {
    _closed = true;
    _timer?.cancel();
    _timer = null;
    _pending.clear();
    unawaited(_missingChanges.close());
  }
}

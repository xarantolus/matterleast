import 'dart:io';

import 'package:drift/drift.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/server_status.dart';

/// How much one server has stored: channels, posts and the file size.
Stream<StoredCounts> storedCounts(ServerDatabase db, String path) =>
    throttledWatch(
      db.tableUpdates(TableUpdateQuery.onAllTables([db.channels, db.posts])),
      () async {
        final channels = db.channels.id.count();
        final posts = db.posts.id.count();
        final file = File(path);
        var bytes = file.existsSync() ? await file.length() : 0;
        final wal = File('$path-wal');
        if (wal.existsSync()) bytes += await wal.length();
        return (
          channels:
              (await (db.selectOnly(
                db.channels,
              )..addColumns([channels])).getSingle()).read(channels) ??
              0,
          posts:
              (await (db.selectOnly(
                db.posts,
              )..addColumns([posts])).getSingle()).read(posts) ??
              0,
          bytes: bytes,
        );
      },
      interval: const Duration(seconds: 1),
    ).distinct();

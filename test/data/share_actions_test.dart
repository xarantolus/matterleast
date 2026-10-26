import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/actions/share_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late Directory dir;
  late List<String> files;
  var uploads = 0;

  /// Lets a test hold an upload's answer back.
  Completer<void>? holdUpload;

  setUp(() async {
    uploads = 0;
    holdUpload = null;
    dir = await Directory.systemTemp.createTemp('share');
    files = [
      (await File('${dir.path}/tide.txt').writeAsString('low at six')).path,
      (await File('${dir.path}/chart.txt').writeAsString('x' * 100)).path,
    ];
    server = await FakeServer.start();
    server.handle = (r) async {
      if (r.method == 'POST' && r.path == '/api/v4/files') {
        await holdUpload?.future;
        final n = ++uploads;
        final name = RegExp(r'filename="([^"]+)"').firstMatch(r.text)![1];
        return ok({
          'file_infos': [
            {'id': 'file$n', 'name': name, 'channel_id': channelId},
          ],
          'client_ids': ['c$n'],
        });
      }
      return error(404, 'not_found');
    };
    session = await testSession(server);
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
    await dir.delete(recursive: true);
  });

  test(
    'shared files go up with progress, then one post carries them',
    () async {
      final progress = <double>[];
      await sendShared(
        session,
        channelId: channelId,
        message: 'For the crew',
        files: files,
        onProgress: progress.add,
      );
      final db = session.db;
      final post = await (db.select(
        db.posts,
      )..where((p) => p.message.equals('For the crew'))).getSingle();
      final attached = await (db.select(
        db.files,
      )..where((f) => f.postId.equals(post.id))).get();

      expect(uploads, 2);
      expect(post.fileCount, 2);
      expect(attached.map((f) => f.id), unorderedEquals(['file1', 'file2']));
      expect(progress, isNotEmpty);
      expect(progress.last, closeTo(1, 0.001));
      expect(progress, orderedEquals([...progress]..sort()));
    },
  );

  test('cancelling stops the uploads and sends nothing', () async {
    holdUpload = Completer();
    final cancel = Completer<void>();
    final send = sendShared(
      session,
      channelId: channelId,
      message: 'For the crew',
      files: files,
      cancel: cancel.future,
    );
    for (var i = 0; i < 100 && server.seen.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    cancel.complete();
    await expectLater(send, throwsA(isA<Cancelled>()));
    holdUpload!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final db = session.db;
    final queued = await (db.select(
      db.posts,
    )..where((p) => p.message.equals('For the crew'))).get();

    expect(uploads, lessThanOrEqualTo(1));
    expect(queued, isEmpty);
  });
}

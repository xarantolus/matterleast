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
    (server, session) = await startServerSession();
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
  });

  tearDown(() async {
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

  test("one refused file sends nothing, keeps the files and says the server's "
      'reason', () async {
    server.handle = (r) {
      if (r.path != '/api/v4/files') return error(404, 'not_found');
      if (r.text.contains('chart.txt')) {
        return (
          status: 413,
          json: {
            'id': 'api.file.upload_file.too_large_detailed.app_error',
            'message':
                'Unable to upload file chart.txt. 100 bytes exceeds the '
                'maximum allowed file size of 10 bytes.',
            'status_code': 413,
          },
          headers: const <String, String>{},
        );
      }
      return ok({
        'file_infos': [
          {'id': 'file1', 'name': 'tide.txt', 'channel_id': channelId},
        ],
      });
    };
    await expectLater(
      sendShared(
        session,
        channelId: channelId,
        message: 'For the crew',
        files: files,
      ),
      throwsA(
        isA<ServerError>().having(
          (e) => e.message,
          'message',
          contains('maximum allowed file size'),
        ),
      ),
    );
    final db = session.db;
    final queued = await (db.select(
      db.posts,
    )..where((p) => p.message.equals('For the crew'))).get();
    expect(queued, isEmpty);
    expect(await db.select(db.outbox).get(), isEmpty);
    for (final path in files) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}

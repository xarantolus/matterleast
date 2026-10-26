import 'dart:async';
import 'dart:io';

import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/file_upload.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:path/path.dart' as p;

/// Sends what another app shared: the files are uploaded first, then one
/// post goes through the outbox like any message. [onProgress] goes from 0
/// to 1 over all files' bytes; when [cancel] completes, the running upload
/// stops and the send fails with [Cancelled].
Future<void> sendShared(
  ServerSession session, {
  required String channelId,
  required String message,
  required List<String> files,
  void Function(double progress)? onProgress,
  Future<void>? cancel,
}) async {
  final sizes = [for (final path in files) await File(path).length()];
  final total = sizes.fold(0, (a, b) => a + b);
  var done = 0;
  var cancelled = false;
  FileUpload? running;
  unawaited(
    cancel?.then((_) {
      cancelled = true;
      running?.cancel();
    }),
  );
  final uploaded = <api.FileInfo>[];
  for (final (i, path) in files.indexed) {
    if (cancelled) throw const Cancelled();
    final upload = running = FileUpload.start(
      session.api,
      channelId: channelId,
      open: File(path).openRead,
      length: sizes[i],
      name: p.basename(path),
      clientId: '${DateTime.now().microsecondsSinceEpoch}-$i',
    );
    final progress = upload.progress.listen((part) {
      if (total > 0) onProgress?.call((done + part * sizes[i]) / total);
    });
    try {
      uploaded.add(await upload.done);
    } finally {
      await progress.cancel();
    }
    done += sizes[i];
  }
  running = null;
  if (cancelled) throw const Cancelled();
  await ComposerActions(session)
      .send(channelId, message: message, files: uploaded);
}

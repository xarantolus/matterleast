import 'package:dio/dio.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:path/path.dart' as p;

/// Uploads a local file to [channelId] with `POST /files`; the post that
/// carries it is sent separately.
Future<api.FileInfo> uploadFile(
  ServerSession session,
  String channelId,
  String path,
) async {
  final form = FormData.fromMap({
    'channel_id': channelId,
    'files': await MultipartFile.fromFile(path, filename: p.basename(path)),
  });
  final response = await session.api.call(
    () => session.api.dio.post<Map<String, Object?>>(
      '/api/v4/files',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(minutes: 5),
      ),
    ),
  );
  final infos = response.data?['file_infos'];
  if (infos is! List || infos.isEmpty || infos.first is! Map) {
    throw const FormatException('No file info in the upload answer');
  }
  return api.FileInfo.fromJson((infos.first as Map).cast<String, Object?>());
}

/// Sends what another app shared: the files are uploaded first, then one
/// post goes through the outbox like any message.
Future<void> sendShared(
  ServerSession session, {
  required String channelId,
  required String message,
  required List<String> files,
}) async {
  final uploaded = [
    for (final path in files) await uploadFile(session, channelId, path),
  ];
  await ComposerActions(session)
      .send(channelId, message: message, files: uploaded);
}

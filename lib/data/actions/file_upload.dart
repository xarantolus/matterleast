import 'dart:async';

import 'package:dio/dio.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';

/// One file going up to a channel: its progress, the stored file when done,
/// and a way to stop it.
class FileUpload {
  FileUpload._(this._cancel, this.progress, this.done);

  /// Starts uploading the [length] bytes [open] reads for [channelId]. [clientId] lets
  /// the server's answer be matched to this file.
  factory FileUpload.start(
    ServerApi server, {
    required String channelId,
    required Stream<List<int>> Function() open,
    required int length,
    required String name,
    required String clientId,
  }) {
    final cancel = CancelToken();
    final progress = StreamController<double>.broadcast();
    Future<api.FileInfo> run() async {
      try {
        final response = await server.call(
          () => server.dio.post<Object?>(
            '/api/v4/files',
            data: FormData.fromMap({
              'channel_id': channelId,
              'client_ids': clientId,
              'files': MultipartFile.fromStream(open, length, filename: name),
            }),
            options: Options(
              contentType: 'multipart/form-data',
              sendTimeout: uploadTimeout,
              receiveTimeout: uploadTimeout,
            ),
            cancelToken: cancel,
            onSendProgress: (sent, total) {
              if (total > 0 && !progress.isClosed) progress.add(sent / total);
            },
          ),
        );
        final body = response.data;
        final infos = body is Map<String, Object?> ? body['file_infos'] : null;
        if (infos is List && infos.firstOrNull is Map<String, Object?>) {
          return api.FileInfo.fromJson(infos.first as Map<String, Object?>);
        }
        throw const ServerError(statusCode: 0, message: 'No file came back.');
      } finally {
        unawaited(progress.close());
      }
    }

    return FileUpload._(cancel, progress.stream, run());
  }

  static const uploadTimeout = Duration(minutes: 3);

  final CancelToken _cancel;

  /// From 0 to 1 as the bytes go out.
  final Stream<double> progress;

  /// The stored file; fails with an [ApiError], [Cancelled] when stopped.
  final Future<api.FileInfo> done;

  void cancel() => _cancel.cancel();
}

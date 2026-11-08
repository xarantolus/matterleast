import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_providers.g.dart';

@Riverpod(keepAlive: true)
Future<FileDownloads> fileDownloads(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).files;

/// The message files of one server being downloaded: file id → the share
/// received, null while the size is unknown. Kept while the app runs, so a
/// download finishes even when the screen that started it closes.
@Riverpod(keepAlive: true)
class FileTransfers extends _$FileTransfers {
  final _cancels = <String, CancelToken>{};

  @override
  Map<String, double?> build(String url) {
    ref.onDispose(() {
      for (final cancel in _cancels.values) {
        cancel.cancel();
      }
    });
    return const {};
  }

  /// The downloaded file, or null when the download was cancelled.
  Future<File?> fetch(PostFile file) async {
    final downloads = await ref.read(fileDownloadsProvider(url).future);
    final hit = await downloads.cached(file.id);
    if (hit != null) return hit;
    final cancel = _cancels[file.id] ??= CancelToken();
    _set(file.id, null);
    try {
      return await downloads.fetch(
        file,
        cancel: cancel,
        onProgress: (progress) {
          final shown = state[file.id];
          // Whole percent steps are enough for a bar and spare rebuilds.
          if (progress == null ||
              shown == null ||
              (progress - shown).abs() >= 0.01) {
            _set(file.id, progress);
          }
        },
      );
    } on Cancelled {
      return null;
    } finally {
      _cancels.remove(file.id);
      if (ref.mounted) state = {...state}..remove(file.id);
    }
  }

  void cancel(String fileId) => _cancels[fileId]?.cancel();

  void _set(String fileId, double? progress) {
    if (ref.mounted) state = {...state, fileId: progress};
  }
}

/// Whether the file is already on this device; asked again when a download
/// of it starts or ends.
@riverpod
Future<bool> fileDownloaded(Ref ref, String url, String fileId) async {
  ref.watch(fileTransfersProvider(url).select((t) => t.containsKey(fileId)));
  final downloads = await ref.watch(fileDownloadsProvider(url).future);
  return await downloads.cached(fileId) != null;
}

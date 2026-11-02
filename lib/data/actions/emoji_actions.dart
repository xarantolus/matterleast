import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/emoji_rules.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/log.dart';

/// Finding, adding and removing the server's custom emoji. What comes back
/// is stored, where every screen picks it up.
class EmojiActions {
  EmojiActions(this.session);

  final ServerSession session;

  final _searching = <String, Future<void>>{};
  final _searched = <String>{};

  /// Asks the server for custom emoji whose name contains [term] and stores
  /// them. One ask per term; a term already asked for is not asked again.
  Future<void> search(String term) {
    if (_searched.contains(term)) return Future.value();
    return _searching[term] ??= _search(term).whenComplete(() {
      _searching.remove(term);
    });
  }

  Future<void> _search(String term) async {
    if (!(await session.db.features()).customEmoji) return;
    try {
      final response = await session.api.call(
        () => session.api.dio.post<List<Object?>>(
          '/api/v4/emoji/search',
          data: {'term': term, 'prefix_only': false},
          options: Options(responseType: ResponseType.json),
        ),
      );
      _searched.add(term);
      await session.store.applyCustomEmoji(_decode(response.data));
    } on ApiError catch (e) {
      if (endpointUnavailable(e)) {
        await session.store.turnOff(OptionalFeature.customEmoji);
      }
      Log.info('emoji', 'Searching custom emoji failed: ${e.runtimeType}');
    }
  }

  static List<api.Emoji> _decode(List<Object?>? items) => [
    for (final item in items ?? const <Object?>[])
      if (item is Map<String, Object?>) ?decodeOrSkip(item, api.Emoji.fromJson),
  ];

  /// Uploads [bytes] as the new custom emoji [name]; stored at once, so it
  /// is usable before the socket reports it.
  Future<void> add({
    required String name,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final me = await session.db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('No signed-in user');
    final type = emojiImageType(fileName)?.split('/');
    final api.Emoji created;
    try {
      final response = await session.api.call(
        () => session.api.dio.post<Map<String, Object?>>(
          '/api/v4/emoji',
          data: FormData.fromMap({
            'image': MultipartFile.fromBytes(
              bytes,
              filename: fileName,
              contentType: type == null
                  ? null
                  : DioMediaType(type.first, type.last),
            ),
            'emoji': jsonEncode(api.Emoji(creatorId: me, name: name).toJson()),
          }),
          options: Options(
            contentType: 'multipart/form-data',
            responseType: ResponseType.json,
            sendTimeout: _uploadTimeout,
            receiveTimeout: _uploadTimeout,
          ),
        ),
        deadline: ServerApi.transferDeadline,
      );
      created = api.Emoji.fromJson(response.data ?? const {});
    } on ApiError catch (e) {
      if (endpointUnavailable(e)) {
        await session.store.turnOff(OptionalFeature.customEmoji);
      }
      rethrow;
    }
    await session.store.applyCustomEmoji([created]);
  }

  static const _uploadTimeout = Duration(minutes: 2);

  /// Deletes the custom emoji [id]; it goes from the picker at once.
  Future<void> delete(String id) async {
    await session.api.call(
      () => session.api.dio.delete<Object?>('/api/v4/emoji/$id'),
    );
    await session.store.removeCustomEmoji(id);
  }
}

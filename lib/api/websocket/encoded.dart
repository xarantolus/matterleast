import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/websocket/dialog.dart';

/// Many WebSocket payload fields are JSON strings that hold JSON. These
/// converters decode them a second time; anything malformed becomes null
/// (or empty), so a bad event is skipped rather than thrown.
Object? decodeJsonString(Object? value) {
  if (value is! String || value.isEmpty) return value;
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}

Map<String, Object?>? _object(Object? value) {
  final decoded = decodeJsonString(value);
  return decoded is Map<String, Object?> ? decoded : null;
}

List<Map<String, Object?>> _objects(Object? value) {
  final decoded = decodeJsonString(value);
  if (decoded is Map<String, Object?>) return [decoded];
  if (decoded is! List) return const [];
  return [
    for (final e in decoded)
      if (e is Map<String, Object?>) e,
  ];
}

abstract class _Decoding<T> implements JsonConverter<T, Object?> {
  const _Decoding();
  @override
  Object? toJson(T object) => throw UnsupportedError('decode only');
}

class EncodedPost extends _Decoding<api.Post?> {
  const EncodedPost();
  @override
  api.Post? fromJson(Object? json) => _object(json).let(api.Post.fromJson);
}

class EncodedChannel extends _Decoding<api.Channel?> {
  const EncodedChannel();
  @override
  api.Channel? fromJson(Object? json) =>
      _object(json).let(api.Channel.fromJson);
}

class EncodedChannelMember extends _Decoding<api.ChannelMember?> {
  const EncodedChannelMember();
  @override
  api.ChannelMember? fromJson(Object? json) =>
      _object(json).let(api.ChannelMember.fromJson);
}

class EncodedTeam extends _Decoding<api.Team?> {
  const EncodedTeam();
  @override
  api.Team? fromJson(Object? json) => _object(json).let(api.Team.fromJson);
}

class EncodedReaction extends _Decoding<api.Reaction?> {
  const EncodedReaction();
  @override
  api.Reaction? fromJson(Object? json) =>
      _object(json).let(api.Reaction.fromJson);
}

class EncodedEmoji extends _Decoding<api.Emoji?> {
  const EncodedEmoji();
  @override
  api.Emoji? fromJson(Object? json) => _object(json).let(api.Emoji.fromJson);
}

class EncodedThread extends _Decoding<api.UserThread?> {
  const EncodedThread();
  @override
  api.UserThread? fromJson(Object? json) =>
      _object(json).let(api.UserThread.fromJson);
}

/// One preference or a list of them.
class EncodedPreferences extends _Decoding<List<api.Preference>> {
  const EncodedPreferences();
  @override
  List<api.Preference> fromJson(Object? json) => [
    for (final p in _objects(json)) api.Preference.fromJson(p),
  ];
}

class EncodedCategories
    extends _Decoding<List<api.SidebarCategoryWithChannels>> {
  const EncodedCategories();
  @override
  List<api.SidebarCategoryWithChannels> fromJson(Object? json) => [
    for (final c in _objects(json)) api.SidebarCategoryWithChannels.fromJson(c),
  ];
}

class EncodedStringList extends _Decoding<List<String>> {
  const EncodedStringList();
  @override
  List<String> fromJson(Object? json) => switch (decodeJsonString(json)) {
    final List<Object?> list => [
      for (final e in list)
        if (e is String) e,
    ],
    _ => const [],
  };
}

/// Channel id → time in milliseconds, as in `multiple_channels_viewed`.
class TimesById extends _Decoding<Map<String, DateTime>> {
  const TimesById();
  @override
  Map<String, DateTime> fromJson(Object? json) => {
    if (json is Map<String, Object?>)
      for (final MapEntry(:key, :value) in json.entries)
        if (value is int && value > 0)
          key: DateTime.fromMillisecondsSinceEpoch(value, isUtc: true),
  };
}

class EncodedDialog extends _Decoding<OpenDialog?> {
  const EncodedDialog();
  @override
  OpenDialog? fromJson(Object? json) => _object(json).let(OpenDialog.fromJson);
}

class UserObject extends _Decoding<api.User?> {
  const UserObject();
  @override
  api.User? fromJson(Object? json) => json is Map<String, Object?>
      ? decodeOrSkip(json, api.User.fromJson)
      : null;
}

extension on Map<String, Object?>? {
  R? let<R extends Object>(R Function(Map<String, Object?>) decode) {
    final json = this;
    return json == null ? null : decodeOrSkip(json, decode);
  }
}

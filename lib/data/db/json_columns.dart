import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/lenient.dart';

// JSON kept in text columns, decoded once where it leaves the database.
// Text that doesn't decode (rows written by an older build, or another
// party's odd JSON stored as it came) reads as empty or null instead of
// failing the query.

/// [value] as stored JSON text.
String storedJson(Object? value) => jsonEncode(value, toEncodable: _encodable);

// Generated enums throw on toJson for values the spec does not list (a newer
// server's embed type, say); those are stored as null instead.
Object? _encodable(Object? value) => switch (value) {
  api.Type2(:final json) => json,
  api.PostPriorityPriority(:final json) => json,
  final api.Post v => v.toJson(),
  final api.PostMetadata v => v.toJson(),
  final api.Embeds v => v.toJson(),
  final api.Emoji v => v.toJson(),
  final api.FileInfo v => v.toJson(),
  final api.Reaction v => v.toJson(),
  final api.PostPriority v => v.toJson(),
  final api.PostAcknowledgement v => v.toJson(),
  final api.User v => v.toJson(),
  _ => throw JsonUnsupportedObjectError(value),
};

Object? _decode(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}

/// Ids or names as a JSON list of strings.
class StringListColumn extends TypeConverter<List<String>, String> {
  const StringListColumn();

  @override
  List<String> fromSql(String fromDb) => switch (_decode(fromDb)) {
    final List<Object?> list => list.whereType<String>().toList(),
    _ => const [],
  };

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// One JSON object, kept as it came.
class JsonMapColumn extends TypeConverter<Map<String, Object?>, String> {
  const JsonMapColumn();

  @override
  Map<String, Object?> fromSql(String fromDb) => switch (_decode(fromDb)) {
    final Map<String, Object?> map => map,
    _ => const {},
  };

  @override
  String toSql(Map<String, Object?> value) => jsonEncode(value);
}

/// One JSON object read into a typed model through its generated code.
abstract class _ModelColumn<T extends Object>
    extends TypeConverter<T?, String?> {
  const _ModelColumn();

  T fromJson(Map<String, Object?> json);
  Map<String, Object?> toJson(T value);

  @override
  T? fromSql(String? fromDb) =>
      switch (fromDb == null ? null : _decode(fromDb)) {
        final Map<String, Object?> map => decodeOrSkip(map, fromJson),
        _ => null,
      };

  @override
  String? toSql(T? value) => value == null ? null : storedJson(toJson(value));
}

class ChannelNotifyPropsColumn extends _ModelColumn<api.ChannelNotifyProps> {
  const ChannelNotifyPropsColumn();

  @override
  api.ChannelNotifyProps fromJson(Map<String, Object?> json) =>
      api.ChannelNotifyProps.fromJson(json);

  @override
  Map<String, Object?> toJson(api.ChannelNotifyProps value) => value.toJson();
}

class TimezoneColumn extends _ModelColumn<api.Timezone> {
  const TimezoneColumn();

  @override
  api.Timezone fromJson(Map<String, Object?> json) =>
      api.Timezone.fromJson(json);

  @override
  Map<String, Object?> toJson(api.Timezone value) => value.toJson();
}

class PostPriorityColumn extends _ModelColumn<api.PostPriority> {
  const PostPriorityColumn();

  @override
  api.PostPriority fromJson(Map<String, Object?> json) =>
      api.PostPriority.fromJson(json);

  @override
  Map<String, Object?> toJson(api.PostPriority value) => value.toJson();
}

/// Files as a JSON list of file infos; one that doesn't read is left out.
class FileInfoListColumn extends TypeConverter<List<api.FileInfo>, String> {
  const FileInfoListColumn();

  @override
  List<api.FileInfo> fromSql(String fromDb) => switch (_decode(fromDb)) {
    final List<Object?> list => [
      for (final item in list)
        if (item is Map<String, Object?>)
          ?decodeOrSkip(item, api.FileInfo.fromJson),
    ],
    _ => const [],
  };

  @override
  String toSql(List<api.FileInfo> value) => storedJson(value);
}

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/log.dart';

/// Decodes one object of another party's JSON; a shape the generated code
/// cannot read drops that object (logged by type, no content) instead of
/// failing the list or page around it.
T? decodeOrSkip<T extends Object>(
  Map<String, Object?> json,
  T Function(Map<String, Object?>) decode,
) {
  try {
    return decode(json);
  } on Object catch (e) {
    final id = json['id'];
    Log.warn(
      'json',
      'skipped unreadable $T${id is String ? ' $id' : ''}: ${e.runtimeType}',
    );
    return null;
  }
}

class LenientString implements JsonConverter<String?, Object?> {
  const LenientString();
  @override
  String? fromJson(Object? json) => json is String ? json : null;
  @override
  Object? toJson(String? object) => object;
}

class LenientInt implements JsonConverter<int?, Object?> {
  const LenientInt();
  @override
  int? fromJson(Object? json) => switch (json) {
    final int v => v,
    final double v when v.isFinite => v.toInt(),
    final String v => int.tryParse(v),
    _ => null,
  };
  @override
  Object? toJson(int? object) => object;
}

class LenientDouble implements JsonConverter<double?, Object?> {
  const LenientDouble();
  @override
  double? fromJson(Object? json) => switch (json) {
    final num v => v.toDouble(),
    final String v => double.tryParse(v),
    _ => null,
  };
  @override
  Object? toJson(double? object) => object;
}

class LenientBool implements JsonConverter<bool?, Object?> {
  const LenientBool();
  @override
  bool? fromJson(Object? json) => switch (json) {
    final bool v => v,
    'true' => true,
    'false' => false,
    _ => null,
  };
  @override
  Object? toJson(bool? object) => object;
}

/// The server sends times as milliseconds since the epoch; 0 means unset.
class MillisDateTime implements JsonConverter<DateTime?, Object?> {
  const MillisDateTime();
  @override
  DateTime? fromJson(Object? json) {
    final ms = const LenientInt().fromJson(json);
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  @override
  Object? toJson(DateTime? object) => object?.millisecondsSinceEpoch ?? 0;
}

class LenientStringList implements JsonConverter<List<String>, Object?> {
  const LenientStringList();
  @override
  List<String> fromJson(Object? json) => json is List
      ? [
          for (final e in json)
            if (e is String) e,
        ]
      : const [];
  @override
  Object? toJson(List<String> object) => object;
}

class JsonMap implements JsonConverter<Map<String, Object?>?, Object?> {
  const JsonMap();
  @override
  Map<String, Object?>? fromJson(Object? json) =>
      json is Map<String, Object?> ? json : null;
  @override
  Object? toJson(Map<String, Object?>? object) => object;
}

class JsonMapOrEmpty implements JsonConverter<Map<String, Object?>, Object?> {
  const JsonMapOrEmpty();
  @override
  Map<String, Object?> fromJson(Object? json) =>
      json is Map<String, Object?> ? json : const {};
  @override
  Object? toJson(Map<String, Object?> object) => object;
}

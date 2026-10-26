// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Type2 {
  @JsonValue('image')
  image('image'),
  @JsonValue('message_attachment')
  messageAttachment('message_attachment'),
  @JsonValue('opengraph')
  opengraph('opengraph'),
  @JsonValue('link')
  link('link'),
  @JsonValue('permalink')
  permalink('permalink'),
  @JsonValue('boards')
  boards('boards'),

  $unknown(null);

  const Type2(this.json);

  factory Type2.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  static List<Type2> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}

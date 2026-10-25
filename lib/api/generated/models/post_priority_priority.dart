// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PostPriorityPriority {
  @JsonValue('')
  empty(''),
  @JsonValue('important')
  important('important'),
  @JsonValue('urgent')
  urgent('urgent'),

  $unknown(null);

  const PostPriorityPriority(this.json);

  factory PostPriorityPriority.fromJson(String json) =>
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

  static List<PostPriorityPriority> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}

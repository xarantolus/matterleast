// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum AccessMode {
  @JsonValue('')
  empty(''),
  @JsonValue('source_only')
  sourceOnly('source_only'),
  @JsonValue('shared_only')
  sharedOnly('shared_only'),

  $unknown(null);

  const AccessMode(this.json);

  factory AccessMode.fromJson(String json) =>
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

  static List<AccessMode> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}

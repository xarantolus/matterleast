// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'timezone.g.dart';

@JsonSerializable()
class Timezone {
  const Timezone({
    this.useAutomaticTimezone,
    this.manualTimezone,
    this.automaticTimezone,
  });

  factory Timezone.fromJson(Map<String, Object?> json) =>
      _$TimezoneFromJson(json);

  @LenientString()
  final String? useAutomaticTimezone;
  @LenientString()
  final String? manualTimezone;
  @LenientString()
  final String? automaticTimezone;

  Map<String, Object?> toJson() => _$TimezoneToJson(this);
}

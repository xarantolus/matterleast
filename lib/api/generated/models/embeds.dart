// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type2.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'embeds.g.dart';

@JsonSerializable()
class Embeds {
  const Embeds({this.type, this.url, this.data});

  factory Embeds.fromJson(Map<String, Object?> json) => _$EmbedsFromJson(json);

  final Type2? type;
  @LenientString()
  final String? url;
  @JsonMap()
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() => _$EmbedsToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_priority.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'metadata.g.dart';

@JsonSerializable()
class Metadata {
  const Metadata({this.priority});

  factory Metadata.fromJson(Map<String, Object?> json) =>
      _$MetadataFromJson(json);

  @LenientPostPriority()
  final PostPriority? priority;

  Map<String, Object?> toJson() => _$MetadataToJson(this);
}

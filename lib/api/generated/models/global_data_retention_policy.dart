// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'global_data_retention_policy.g.dart';

@JsonSerializable()
class GlobalDataRetentionPolicy {
  const GlobalDataRetentionPolicy({
    this.messageDeletionEnabled,
    this.fileDeletionEnabled,
    this.messageRetentionCutoff,
    this.fileRetentionCutoff,
  });

  factory GlobalDataRetentionPolicy.fromJson(Map<String, Object?> json) =>
      _$GlobalDataRetentionPolicyFromJson(json);

  @LenientBool()
  @JsonKey(name: 'message_deletion_enabled')
  final bool? messageDeletionEnabled;

  @LenientBool()
  @JsonKey(name: 'file_deletion_enabled')
  final bool? fileDeletionEnabled;

  @LenientInt()
  @JsonKey(name: 'message_retention_cutoff')
  final int? messageRetentionCutoff;

  @LenientInt()
  @JsonKey(name: 'file_retention_cutoff')
  final int? fileRetentionCutoff;

  Map<String, Object?> toJson() => _$GlobalDataRetentionPolicyToJson(this);
}

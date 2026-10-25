// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_data_retention_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalDataRetentionPolicy _$GlobalDataRetentionPolicyFromJson(
  Map<String, dynamic> json,
) => GlobalDataRetentionPolicy(
  messageDeletionEnabled: const LenientBool().fromJson(
    json['message_deletion_enabled'],
  ),
  fileDeletionEnabled: const LenientBool().fromJson(
    json['file_deletion_enabled'],
  ),
  messageRetentionCutoff: const LenientInt().fromJson(
    json['message_retention_cutoff'],
  ),
  fileRetentionCutoff: const LenientInt().fromJson(
    json['file_retention_cutoff'],
  ),
);

Map<String, dynamic> _$GlobalDataRetentionPolicyToJson(
  GlobalDataRetentionPolicy instance,
) => <String, dynamic>{
  'message_deletion_enabled': const LenientBool().toJson(
    instance.messageDeletionEnabled,
  ),
  'file_deletion_enabled': const LenientBool().toJson(
    instance.fileDeletionEnabled,
  ),
  'message_retention_cutoff': const LenientInt().toJson(
    instance.messageRetentionCutoff,
  ),
  'file_retention_cutoff': const LenientInt().toJson(
    instance.fileRetentionCutoff,
  ),
};

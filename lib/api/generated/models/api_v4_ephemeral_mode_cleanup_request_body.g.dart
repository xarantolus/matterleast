// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_ephemeral_mode_cleanup_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4EphemeralModeCleanupRequestBody
_$ApiV4EphemeralModeCleanupRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4EphemeralModeCleanupRequestBody(
      postsDeleted: const LenientInt().fromJson(json['posts_deleted']),
      playbookRunsDeleted: const LenientInt().fromJson(
        json['playbook_runs_deleted'],
      ),
      cleanupAt: const MillisDateTime().fromJson(json['cleanup_at']),
      errorReason: const LenientString().fromJson(json['error_reason']),
    );

Map<String, dynamic> _$ApiV4EphemeralModeCleanupRequestBodyToJson(
  ApiV4EphemeralModeCleanupRequestBody instance,
) => <String, dynamic>{
  'posts_deleted': const LenientInt().toJson(instance.postsDeleted),
  'playbook_runs_deleted': const LenientInt().toJson(
    instance.playbookRunsDeleted,
  ),
  'cleanup_at': const MillisDateTime().toJson(instance.cleanupAt),
  'error_reason': const LenientString().toJson(instance.errorReason),
};

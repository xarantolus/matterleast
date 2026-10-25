// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_ephemeral_mode_cleanup_request_body.g.dart';

@JsonSerializable()
class ApiV4EphemeralModeCleanupRequestBody {
  const ApiV4EphemeralModeCleanupRequestBody({
    this.postsDeleted,
    this.playbookRunsDeleted,
    this.cleanupAt,
    this.errorReason,
  });

  factory ApiV4EphemeralModeCleanupRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4EphemeralModeCleanupRequestBodyFromJson(json);

  @LenientInt()
  @JsonKey(name: 'posts_deleted')
  final int? postsDeleted;

  @LenientInt()
  @JsonKey(name: 'playbook_runs_deleted')
  final int? playbookRunsDeleted;

  @MillisDateTime()
  @JsonKey(name: 'cleanup_at')
  final DateTime? cleanupAt;

  @LenientString()
  @JsonKey(name: 'error_reason')
  final String? errorReason;

  Map<String, Object?> toJson() =>
      _$ApiV4EphemeralModeCleanupRequestBodyToJson(this);
}

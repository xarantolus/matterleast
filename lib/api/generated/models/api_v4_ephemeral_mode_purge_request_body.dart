// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_ephemeral_mode_purge_request_body.g.dart';

@JsonSerializable()
class ApiV4EphemeralModePurgeRequestBody {
  const ApiV4EphemeralModePurgeRequestBody({
    this.offlineTimeMinutes,
    this.purgeAt,
    this.errorReason,
  });

  factory ApiV4EphemeralModePurgeRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4EphemeralModePurgeRequestBodyFromJson(json);

  @LenientInt()
  @JsonKey(name: 'offline_time_minutes')
  final int? offlineTimeMinutes;

  @MillisDateTime()
  @JsonKey(name: 'purge_at')
  final DateTime? purgeAt;

  @LenientString()
  @JsonKey(name: 'error_reason')
  final String? errorReason;

  Map<String, Object?> toJson() =>
      _$ApiV4EphemeralModePurgeRequestBodyToJson(this);
}

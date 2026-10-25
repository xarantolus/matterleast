// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_ephemeral_mode_wipe_request_body.g.dart';

@JsonSerializable()
class ApiV4EphemeralModeWipeRequestBody {
  const ApiV4EphemeralModeWipeRequestBody({
    required this.signature,
    this.wipeAt,
    this.errorReason,
  });

  factory ApiV4EphemeralModeWipeRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4EphemeralModeWipeRequestBodyFromJson(json);

  final String signature;

  @MillisDateTime()
  @JsonKey(name: 'wipe_at')
  final DateTime? wipeAt;

  @LenientString()
  @JsonKey(name: 'error_reason')
  final String? errorReason;

  Map<String, Object?> toJson() =>
      _$ApiV4EphemeralModeWipeRequestBodyToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_content_flagging_post_post_id_flag_request_body.g.dart';

@JsonSerializable()
class ApiV4ContentFlaggingPostPostIdFlagRequestBody {
  const ApiV4ContentFlaggingPostPostIdFlagRequestBody({
    this.reason,
    this.comment,
  });

  factory ApiV4ContentFlaggingPostPostIdFlagRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ContentFlaggingPostPostIdFlagRequestBodyFromJson(json);

  @LenientString()
  final String? reason;
  @LenientString()
  final String? comment;

  Map<String, Object?> toJson() =>
      _$ApiV4ContentFlaggingPostPostIdFlagRequestBodyToJson(this);
}

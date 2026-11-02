// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_content_flagging_flag_config_response.g.dart';

@JsonSerializable()
class GetApiV4ContentFlaggingFlagConfigResponse {
  const GetApiV4ContentFlaggingFlagConfigResponse({
    this.reporterCommentRequired,
    this.reasons = const [],
  });

  factory GetApiV4ContentFlaggingFlagConfigResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV4ContentFlaggingFlagConfigResponseFromJson(json);

  @LenientStringList()
  final List<String> reasons;
  @LenientBool()
  @JsonKey(name: 'reporter_comment_required')
  final bool? reporterCommentRequired;

  Map<String, Object?> toJson() =>
      _$GetApiV4ContentFlaggingFlagConfigResponseToJson(this);
}

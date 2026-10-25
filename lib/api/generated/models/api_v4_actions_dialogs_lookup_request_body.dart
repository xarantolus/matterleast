// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_actions_dialogs_lookup_request_body.g.dart';

@JsonSerializable()
class ApiV4ActionsDialogsLookupRequestBody {
  const ApiV4ActionsDialogsLookupRequestBody({
    required this.url,
    required this.channelId,
    required this.submission,
    this.teamId,
    this.callbackId,
    this.state,
  });

  factory ApiV4ActionsDialogsLookupRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ActionsDialogsLookupRequestBodyFromJson(json);

  final String url;

  @JsonKey(name: 'channel_id')
  final String channelId;

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  @JsonMapOrEmpty()
  final Map<String, Object?> submission;

  @LenientString()
  @JsonKey(name: 'callback_id')
  final String? callbackId;

  @LenientString()
  final String? state;

  Map<String, Object?> toJson() =>
      _$ApiV4ActionsDialogsLookupRequestBodyToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_actions_dialogs_execute_request_body.g.dart';

@JsonSerializable()
class ApiV4ActionsDialogsExecuteRequestBody {
  const ApiV4ActionsDialogsExecuteRequestBody({
    required this.url,
    required this.channelId,
    this.context,
    this.teamId,
  });

  factory ApiV4ActionsDialogsExecuteRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ActionsDialogsExecuteRequestBodyFromJson(json);

  final String url;
  @JsonMap()
  final Map<String, Object?>? context;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  Map<String, Object?> toJson() =>
      _$ApiV4ActionsDialogsExecuteRequestBodyToJson(this);
}

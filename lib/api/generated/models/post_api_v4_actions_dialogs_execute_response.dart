// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_actions_dialogs_execute_response.g.dart';

@JsonSerializable()
class PostApiV4ActionsDialogsExecuteResponse {
  const PostApiV4ActionsDialogsExecuteResponse({this.status, this.triggerId});

  factory PostApiV4ActionsDialogsExecuteResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4ActionsDialogsExecuteResponseFromJson(json);

  @LenientString()
  final String? status;
  @LenientString()
  @JsonKey(name: 'trigger_id')
  final String? triggerId;

  Map<String, Object?> toJson() =>
      _$PostApiV4ActionsDialogsExecuteResponseToJson(this);
}

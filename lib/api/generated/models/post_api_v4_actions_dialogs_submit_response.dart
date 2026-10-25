// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_actions_dialogs_submit_response.g.dart';

@JsonSerializable()
class PostApiV4ActionsDialogsSubmitResponse {
  const PostApiV4ActionsDialogsSubmitResponse({this.error, this.errors});

  factory PostApiV4ActionsDialogsSubmitResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4ActionsDialogsSubmitResponseFromJson(json);

  @LenientString()
  final String? error;
  final Map<String, String>? errors;

  Map<String, Object?> toJson() =>
      _$PostApiV4ActionsDialogsSubmitResponseToJson(this);
}

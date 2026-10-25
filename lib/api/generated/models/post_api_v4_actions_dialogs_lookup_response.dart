// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'options.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'post_api_v4_actions_dialogs_lookup_response.g.dart';

@JsonSerializable()
class PostApiV4ActionsDialogsLookupResponse {
  const PostApiV4ActionsDialogsLookupResponse({this.options = const []});

  factory PostApiV4ActionsDialogsLookupResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4ActionsDialogsLookupResponseFromJson(json);

  @LenientListOfOptions()
  final List<Options> options;

  Map<String, Object?> toJson() =>
      _$PostApiV4ActionsDialogsLookupResponseToJson(this);
}

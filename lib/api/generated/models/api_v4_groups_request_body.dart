// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_groups_request_body.g.dart';

@JsonSerializable()
class ApiV4GroupsRequestBody {
  const ApiV4GroupsRequestBody({
    required this.name,
    required this.displayName,
    required this.source,
    required this.allowReference,
    this.userIds = const [],
  });

  factory ApiV4GroupsRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4GroupsRequestBodyFromJson(json);

  final String name;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String source;
  @JsonKey(name: 'allow_reference')
  final bool allowReference;
  @LenientStringList()
  @JsonKey(name: 'user_ids')
  final List<String> userIds;

  Map<String, Object?> toJson() => _$ApiV4GroupsRequestBodyToJson(this);
}

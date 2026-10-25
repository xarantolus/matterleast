// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsRequestBody _$ApiV4TeamsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsRequestBody(
  name: json['name'] as String,
  displayName: json['display_name'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$ApiV4TeamsRequestBodyToJson(
  ApiV4TeamsRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'display_name': instance.displayName,
  'type': instance.type,
};

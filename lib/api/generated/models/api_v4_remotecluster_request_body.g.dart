// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_remotecluster_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4RemoteclusterRequestBody _$ApiV4RemoteclusterRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4RemoteclusterRequestBody(
  name: json['name'] as String,
  defaultTeamId: json['default_team_id'] as String,
  displayName: const LenientString().fromJson(json['display_name']),
  password: const LenientString().fromJson(json['password']),
);

Map<String, dynamic> _$ApiV4RemoteclusterRequestBodyToJson(
  ApiV4RemoteclusterRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'display_name': const LenientString().toJson(instance.displayName),
  'default_team_id': instance.defaultTeamId,
  'password': const LenientString().toJson(instance.password),
};

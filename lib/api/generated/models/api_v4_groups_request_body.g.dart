// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_groups_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4GroupsRequestBody _$ApiV4GroupsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4GroupsRequestBody(
  name: json['name'] as String,
  displayName: json['display_name'] as String,
  source: json['source'] as String,
  allowReference: json['allow_reference'] as bool,
  userIds: json['user_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['user_ids']),
);

Map<String, dynamic> _$ApiV4GroupsRequestBodyToJson(
  ApiV4GroupsRequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'display_name': instance.displayName,
  'source': instance.source,
  'allow_reference': instance.allowReference,
  'user_ids': const LenientStringList().toJson(instance.userIds),
};

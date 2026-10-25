// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsRequestBody _$ApiV4ChannelsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsRequestBody(
  teamId: json['team_id'] as String,
  name: json['name'] as String,
  displayName: json['display_name'] as String,
  type: json['type'] as String,
  purpose: const LenientString().fromJson(json['purpose']),
  header: const LenientString().fromJson(json['header']),
  managedCategoryName: const LenientString().fromJson(
    json['managed_category_name'],
  ),
  defaultCategoryName: const LenientString().fromJson(
    json['default_category_name'],
  ),
);

Map<String, dynamic> _$ApiV4ChannelsRequestBodyToJson(
  ApiV4ChannelsRequestBody instance,
) => <String, dynamic>{
  'team_id': instance.teamId,
  'name': instance.name,
  'display_name': instance.displayName,
  'purpose': const LenientString().toJson(instance.purpose),
  'header': const LenientString().toJson(instance.header),
  'type': instance.type,
  'managed_category_name': const LenientString().toJson(
    instance.managedCategoryName,
  ),
  'default_category_name': const LenientString().toJson(
    instance.defaultCategoryName,
  ),
};

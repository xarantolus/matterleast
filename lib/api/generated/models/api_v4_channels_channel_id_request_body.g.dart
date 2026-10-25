// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdRequestBody _$ApiV4ChannelsChannelIdRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsChannelIdRequestBody(
  id: json['id'] as String,
  name: const LenientString().fromJson(json['name']),
  displayName: const LenientString().fromJson(json['display_name']),
  purpose: const LenientString().fromJson(json['purpose']),
  header: const LenientString().fromJson(json['header']),
);

Map<String, dynamic> _$ApiV4ChannelsChannelIdRequestBodyToJson(
  ApiV4ChannelsChannelIdRequestBody instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': const LenientString().toJson(instance.name),
  'display_name': const LenientString().toJson(instance.displayName),
  'purpose': const LenientString().toJson(instance.purpose),
  'header': const LenientString().toJson(instance.header),
};

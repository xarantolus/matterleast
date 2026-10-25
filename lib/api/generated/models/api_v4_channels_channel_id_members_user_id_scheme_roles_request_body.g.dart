// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_members_user_id_scheme_roles_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody
_$ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody(
  schemeAdmin: json['scheme_admin'] as bool,
  schemeUser: json['scheme_user'] as bool,
);

Map<String, dynamic>
_$ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBodyToJson(
  ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody instance,
) => <String, dynamic>{
  'scheme_admin': instance.schemeAdmin,
  'scheme_user': instance.schemeUser,
};

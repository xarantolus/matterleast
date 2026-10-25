// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_channels_channel_id_members_user_id_scheme_roles_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody {
  const ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody({
    required this.schemeAdmin,
    required this.schemeUser,
  });

  factory ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBody.fromJson(
    Map<String, Object?> json,
  ) =>
      _$ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBodyFromJson(json);

  @JsonKey(name: 'scheme_admin')
  final bool schemeAdmin;
  @JsonKey(name: 'scheme_user')
  final bool schemeUser;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdMembersUserIdSchemeRolesRequestBodyToJson(this);
}

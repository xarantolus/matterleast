// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v4_teams_invite_invite_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV4TeamsInviteInviteIdResponse
_$GetApiV4TeamsInviteInviteIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV4TeamsInviteInviteIdResponse(
      id: const LenientString().fromJson(json['id']),
      name: const LenientString().fromJson(json['name']),
      displayName: const LenientString().fromJson(json['display_name']),
      description: const LenientString().fromJson(json['description']),
    );

Map<String, dynamic> _$GetApiV4TeamsInviteInviteIdResponseToJson(
  GetApiV4TeamsInviteInviteIdResponse instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'name': const LenientString().toJson(instance.name),
  'display_name': const LenientString().toJson(instance.displayName),
  'description': const LenientString().toJson(instance.description),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
  teamId: const LenientString().fromJson(json['team_id']),
  userId: const LenientString().fromJson(json['user_id']),
  roles: const LenientString().fromJson(json['roles']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  schemeUser: const LenientBool().fromJson(json['scheme_user']),
  schemeAdmin: const LenientBool().fromJson(json['scheme_admin']),
  explicitRoles: const LenientString().fromJson(json['explicit_roles']),
  schemeGuest: const LenientBool().fromJson(json['scheme_guest']),
);

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      'team_id': const LenientString().toJson(instance.teamId),
      'user_id': const LenientString().toJson(instance.userId),
      'roles': const LenientString().toJson(instance.roles),
      'delete_at': const MillisDateTime().toJson(instance.deleteAt),
      'scheme_user': const LenientBool().toJson(instance.schemeUser),
      'scheme_admin': const LenientBool().toJson(instance.schemeAdmin),
      'explicit_roles': const LenientString().toJson(instance.explicitRoles),
      'scheme_guest': const LenientBool().toJson(instance.schemeGuest),
    };

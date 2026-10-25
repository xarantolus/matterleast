// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'team_member.g.dart';

@JsonSerializable()
class TeamMember {
  const TeamMember({
    this.teamId,
    this.userId,
    this.roles,
    this.deleteAt,
    this.schemeUser,
    this.schemeAdmin,
    this.explicitRoles,
    this.schemeGuest,
  });

  factory TeamMember.fromJson(Map<String, Object?> json) =>
      _$TeamMemberFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  final String? roles;

  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;

  @LenientBool()
  @JsonKey(name: 'scheme_user')
  final bool? schemeUser;

  @LenientBool()
  @JsonKey(name: 'scheme_admin')
  final bool? schemeAdmin;

  @LenientString()
  @JsonKey(name: 'explicit_roles')
  final String? explicitRoles;
  @LenientBool()
  @JsonKey(name: 'scheme_guest')
  final bool? schemeGuest;

  Map<String, Object?> toJson() => _$TeamMemberToJson(this);
}

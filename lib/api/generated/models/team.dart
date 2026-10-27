// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'team.g.dart';

@JsonSerializable()
class Team {
  const Team({
    this.id,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.displayName,
    this.name,
    this.description,
    this.email,
    this.type,
    this.allowedDomains,
    this.inviteId,
    this.allowOpenInvite,
    this.policyId,
    this.lastTeamIconUpdate,
  });

  factory Team.fromJson(Map<String, Object?> json) => _$TeamFromJson(json);

  @LenientString()
  final String? id;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? name;
  @LenientString()
  final String? description;
  @LenientString()
  final String? email;
  @LenientString()
  final String? type;
  @LenientString()
  @JsonKey(name: 'allowed_domains')
  final String? allowedDomains;
  @LenientString()
  @JsonKey(name: 'invite_id')
  final String? inviteId;
  @LenientBool()
  @JsonKey(name: 'allow_open_invite')
  final bool? allowOpenInvite;
  @LenientString()
  @JsonKey(name: 'policy_id')
  final String? policyId;
  @MillisDateTime()
  @JsonKey(name: 'last_team_icon_update')
  final DateTime? lastTeamIconUpdate;

  Map<String, Object?> toJson() => _$TeamToJson(this);
}

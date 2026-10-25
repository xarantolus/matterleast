// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'team_member.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'session.g.dart';

@JsonSerializable()
class Session {
  const Session({
    this.teamMembers = const [],
    this.createAt,
    this.deviceId,
    this.voipDeviceId,
    this.expiresAt,
    this.id,
    this.isOauth,
    this.lastActivityAt,
    this.props,
    this.roles,
    this.token,
    this.userId,
  });

  factory Session.fromJson(Map<String, Object?> json) =>
      _$SessionFromJson(json);

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @LenientString()
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @LenientString()
  @JsonKey(name: 'voip_device_id')
  final String? voipDeviceId;

  @MillisDateTime()
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @LenientString()
  final String? id;
  @LenientBool()
  @JsonKey(name: 'is_oauth')
  final bool? isOauth;

  @MillisDateTime()
  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientString()
  final String? roles;
  @LenientListOfTeamMember()
  @JsonKey(name: 'team_members')
  final List<TeamMember> teamMembers;
  @LenientString()
  final String? token;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  Map<String, Object?> toJson() => _$SessionToJson(this);
}

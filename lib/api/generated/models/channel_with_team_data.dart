// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_with_team_data.g.dart';

@JsonSerializable()
class ChannelWithTeamData {
  const ChannelWithTeamData({
    this.id,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.teamId,
    this.type,
    this.displayName,
    this.name,
    this.header,
    this.purpose,
    this.lastPostAt,
    this.totalMsgCount,
    this.extraUpdateAt,
    this.creatorId,
    this.totalMsgCountRoot,
    this.lastRootPostAt,
    this.groupConstrained,
    this.shared,
    this.schemeId,
    this.props,
    this.teamDisplayName,
    this.teamName,
    this.teamUpdateAt,
    this.policyId,
  });

  factory ChannelWithTeamData.fromJson(Map<String, Object?> json) =>
      _$ChannelWithTeamDataFromJson(json);

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
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  final String? type;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? name;
  @LenientString()
  final String? header;
  @LenientString()
  final String? purpose;

  @MillisDateTime()
  @JsonKey(name: 'last_post_at')
  final DateTime? lastPostAt;
  @LenientInt()
  @JsonKey(name: 'total_msg_count')
  final int? totalMsgCount;

  @MillisDateTime()
  @JsonKey(name: 'extra_update_at')
  final DateTime? extraUpdateAt;
  @LenientString()
  @JsonKey(name: 'creator_id')
  final String? creatorId;
  @LenientInt()
  @JsonKey(name: 'total_msg_count_root')
  final int? totalMsgCountRoot;
  @MillisDateTime()
  @JsonKey(name: 'last_root_post_at')
  final DateTime? lastRootPostAt;
  @LenientBool()
  @JsonKey(name: 'group_constrained')
  final bool? groupConstrained;
  @LenientBool()
  final bool? shared;
  @LenientString()
  @JsonKey(name: 'scheme_id')
  final String? schemeId;
  final Object? props;

  @LenientString()
  @JsonKey(name: 'team_display_name')
  final String? teamDisplayName;

  @LenientString()
  @JsonKey(name: 'team_name')
  final String? teamName;

  @MillisDateTime()
  @JsonKey(name: 'team_update_at')
  final DateTime? teamUpdateAt;

  @LenientString()
  @JsonKey(name: 'policy_id')
  final String? policyId;

  Map<String, Object?> toJson() => _$ChannelWithTeamDataToJson(this);
}

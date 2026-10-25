// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_with_team_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelWithTeamData _$ChannelWithTeamDataFromJson(
  Map<String, dynamic> json,
) => ChannelWithTeamData(
  id: const LenientString().fromJson(json['id']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  teamId: const LenientString().fromJson(json['team_id']),
  type: const LenientString().fromJson(json['type']),
  displayName: const LenientString().fromJson(json['display_name']),
  name: const LenientString().fromJson(json['name']),
  header: const LenientString().fromJson(json['header']),
  purpose: const LenientString().fromJson(json['purpose']),
  lastPostAt: const MillisDateTime().fromJson(json['last_post_at']),
  totalMsgCount: const LenientInt().fromJson(json['total_msg_count']),
  extraUpdateAt: const MillisDateTime().fromJson(json['extra_update_at']),
  creatorId: const LenientString().fromJson(json['creator_id']),
  totalMsgCountRoot: const LenientInt().fromJson(json['total_msg_count_root']),
  lastRootPostAt: const MillisDateTime().fromJson(json['last_root_post_at']),
  groupConstrained: const LenientBool().fromJson(json['group_constrained']),
  shared: const LenientBool().fromJson(json['shared']),
  schemeId: const LenientString().fromJson(json['scheme_id']),
  props: json['props'],
  teamDisplayName: const LenientString().fromJson(json['team_display_name']),
  teamName: const LenientString().fromJson(json['team_name']),
  teamUpdateAt: const MillisDateTime().fromJson(json['team_update_at']),
  policyId: const LenientString().fromJson(json['policy_id']),
);

Map<String, dynamic> _$ChannelWithTeamDataToJson(
  ChannelWithTeamData instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'team_id': const LenientString().toJson(instance.teamId),
  'type': const LenientString().toJson(instance.type),
  'display_name': const LenientString().toJson(instance.displayName),
  'name': const LenientString().toJson(instance.name),
  'header': const LenientString().toJson(instance.header),
  'purpose': const LenientString().toJson(instance.purpose),
  'last_post_at': const MillisDateTime().toJson(instance.lastPostAt),
  'total_msg_count': const LenientInt().toJson(instance.totalMsgCount),
  'extra_update_at': const MillisDateTime().toJson(instance.extraUpdateAt),
  'creator_id': const LenientString().toJson(instance.creatorId),
  'total_msg_count_root': const LenientInt().toJson(instance.totalMsgCountRoot),
  'last_root_post_at': const MillisDateTime().toJson(instance.lastRootPostAt),
  'group_constrained': const LenientBool().toJson(instance.groupConstrained),
  'shared': const LenientBool().toJson(instance.shared),
  'scheme_id': const LenientString().toJson(instance.schemeId),
  'props': instance.props,
  'team_display_name': const LenientString().toJson(instance.teamDisplayName),
  'team_name': const LenientString().toJson(instance.teamName),
  'team_update_at': const MillisDateTime().toJson(instance.teamUpdateAt),
  'policy_id': const LenientString().toJson(instance.policyId),
};

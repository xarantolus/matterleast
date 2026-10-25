// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retention_policy_for_channel_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetentionPolicyForChannelList _$RetentionPolicyForChannelListFromJson(
  Map<String, dynamic> json,
) => RetentionPolicyForChannelList(
  totalCount: const LenientInt().fromJson(json['total_count']),
  policies: json['policies'] == null
      ? const []
      : const LenientListOfDataRetentionPolicyForChannel().fromJson(
          json['policies'],
        ),
);

Map<String, dynamic> _$RetentionPolicyForChannelListToJson(
  RetentionPolicyForChannelList instance,
) => <String, dynamic>{
  'policies': const LenientListOfDataRetentionPolicyForChannel().toJson(
    instance.policies,
  ),
  'total_count': const LenientInt().toJson(instance.totalCount),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_retention_policy_for_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRetentionPolicyForChannel _$DataRetentionPolicyForChannelFromJson(
  Map<String, dynamic> json,
) => DataRetentionPolicyForChannel(
  channelId: const LenientString().fromJson(json['channel_id']),
  postDuration: const LenientInt().fromJson(json['post_duration']),
);

Map<String, dynamic> _$DataRetentionPolicyForChannelToJson(
  DataRetentionPolicyForChannel instance,
) => <String, dynamic>{
  'channel_id': const LenientString().toJson(instance.channelId),
  'post_duration': const LenientInt().toJson(instance.postDuration),
};

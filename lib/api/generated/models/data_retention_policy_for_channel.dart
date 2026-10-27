// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'data_retention_policy_for_channel.g.dart';

@JsonSerializable()
class DataRetentionPolicyForChannel {
  const DataRetentionPolicyForChannel({this.channelId, this.postDuration});

  factory DataRetentionPolicyForChannel.fromJson(Map<String, Object?> json) =>
      _$DataRetentionPolicyForChannelFromJson(json);

  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientInt()
  @JsonKey(name: 'post_duration')
  final int? postDuration;

  Map<String, Object?> toJson() => _$DataRetentionPolicyForChannelToJson(this);
}

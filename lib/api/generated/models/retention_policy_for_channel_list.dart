// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'data_retention_policy_for_channel.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'retention_policy_for_channel_list.g.dart';

@JsonSerializable()
class RetentionPolicyForChannelList {
  const RetentionPolicyForChannelList({
    this.totalCount,
    this.policies = const [],
  });

  factory RetentionPolicyForChannelList.fromJson(Map<String, Object?> json) =>
      _$RetentionPolicyForChannelListFromJson(json);

  @LenientListOfDataRetentionPolicyForChannel()
  final List<DataRetentionPolicyForChannel> policies;
  @LenientInt()
  @JsonKey(name: 'total_count')
  final int? totalCount;

  Map<String, Object?> toJson() => _$RetentionPolicyForChannelListToJson(this);
}

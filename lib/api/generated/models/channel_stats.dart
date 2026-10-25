// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_stats.g.dart';

@JsonSerializable()
class ChannelStats {
  const ChannelStats({
    this.channelId,
    this.memberCount,
    this.guestCount,
    this.pinnedpostCount,
    this.filesCount,
  });

  factory ChannelStats.fromJson(Map<String, Object?> json) =>
      _$ChannelStatsFromJson(json);

  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientInt()
  @JsonKey(name: 'member_count')
  final int? memberCount;
  @LenientInt()
  @JsonKey(name: 'guest_count')
  final int? guestCount;
  @LenientInt()
  @JsonKey(name: 'pinnedpost_count')
  final int? pinnedpostCount;
  @LenientInt()
  @JsonKey(name: 'files_count')
  final int? filesCount;

  Map<String, Object?> toJson() => _$ChannelStatsToJson(this);
}

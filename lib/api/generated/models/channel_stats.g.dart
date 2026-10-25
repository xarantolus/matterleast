// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelStats _$ChannelStatsFromJson(Map<String, dynamic> json) => ChannelStats(
  channelId: const LenientString().fromJson(json['channel_id']),
  memberCount: const LenientInt().fromJson(json['member_count']),
  guestCount: const LenientInt().fromJson(json['guest_count']),
  pinnedpostCount: const LenientInt().fromJson(json['pinnedpost_count']),
  filesCount: const LenientInt().fromJson(json['files_count']),
);

Map<String, dynamic> _$ChannelStatsToJson(ChannelStats instance) =>
    <String, dynamic>{
      'channel_id': const LenientString().toJson(instance.channelId),
      'member_count': const LenientInt().toJson(instance.memberCount),
      'guest_count': const LenientInt().toJson(instance.guestCount),
      'pinnedpost_count': const LenientInt().toJson(instance.pinnedpostCount),
      'files_count': const LenientInt().toJson(instance.filesCount),
    };

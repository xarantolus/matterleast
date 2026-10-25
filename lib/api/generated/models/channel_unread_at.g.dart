// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_unread_at.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelUnreadAt _$ChannelUnreadAtFromJson(Map<String, dynamic> json) =>
    ChannelUnreadAt(
      teamId: const LenientString().fromJson(json['team_id']),
      channelId: const LenientString().fromJson(json['channel_id']),
      msgCount: const LenientInt().fromJson(json['msg_count']),
      mentionCount: const LenientInt().fromJson(json['mention_count']),
      lastViewedAt: const MillisDateTime().fromJson(json['last_viewed_at']),
    );

Map<String, dynamic> _$ChannelUnreadAtToJson(ChannelUnreadAt instance) =>
    <String, dynamic>{
      'team_id': const LenientString().toJson(instance.teamId),
      'channel_id': const LenientString().toJson(instance.channelId),
      'msg_count': const LenientInt().toJson(instance.msgCount),
      'mention_count': const LenientInt().toJson(instance.mentionCount),
      'last_viewed_at': const MillisDateTime().toJson(instance.lastViewedAt),
    };

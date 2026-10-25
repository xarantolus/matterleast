// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_unread_at.g.dart';

@JsonSerializable()
class ChannelUnreadAt {
  const ChannelUnreadAt({
    this.teamId,
    this.channelId,
    this.msgCount,
    this.mentionCount,
    this.lastViewedAt,
  });

  factory ChannelUnreadAt.fromJson(Map<String, Object?> json) =>
      _$ChannelUnreadAtFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;

  @LenientInt()
  @JsonKey(name: 'msg_count')
  final int? msgCount;

  @LenientInt()
  @JsonKey(name: 'mention_count')
  final int? mentionCount;

  @MillisDateTime()
  @JsonKey(name: 'last_viewed_at')
  final DateTime? lastViewedAt;

  Map<String, Object?> toJson() => _$ChannelUnreadAtToJson(this);
}

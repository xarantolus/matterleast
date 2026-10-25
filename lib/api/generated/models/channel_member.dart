// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'channel_notify_props.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'channel_member.g.dart';

@JsonSerializable()
class ChannelMember {
  const ChannelMember({
    this.channelId,
    this.userId,
    this.roles,
    this.lastViewedAt,
    this.msgCount,
    this.mentionCount,
    this.notifyProps,
    this.lastUpdateAt,
    this.msgCountRoot,
    this.mentionCountRoot,
    this.urgentMentionCount,
    this.schemeUser,
    this.schemeAdmin,
    this.schemeGuest,
  });

  factory ChannelMember.fromJson(Map<String, Object?> json) =>
      _$ChannelMemberFromJson(json);

  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  final String? roles;

  @MillisDateTime()
  @JsonKey(name: 'last_viewed_at')
  final DateTime? lastViewedAt;
  @LenientInt()
  @JsonKey(name: 'msg_count')
  final int? msgCount;
  @LenientInt()
  @JsonKey(name: 'mention_count')
  final int? mentionCount;
  @LenientChannelNotifyProps()
  @JsonKey(name: 'notify_props')
  final ChannelNotifyProps? notifyProps;

  @MillisDateTime()
  @JsonKey(name: 'last_update_at')
  final DateTime? lastUpdateAt;
  @LenientInt()
  @JsonKey(name: 'msg_count_root')
  final int? msgCountRoot;
  @LenientInt()
  @JsonKey(name: 'mention_count_root')
  final int? mentionCountRoot;
  @LenientInt()
  @JsonKey(name: 'urgent_mention_count')
  final int? urgentMentionCount;
  @LenientBool()
  @JsonKey(name: 'scheme_user')
  final bool? schemeUser;
  @LenientBool()
  @JsonKey(name: 'scheme_admin')
  final bool? schemeAdmin;
  @LenientBool()
  @JsonKey(name: 'scheme_guest')
  final bool? schemeGuest;

  Map<String, Object?> toJson() => _$ChannelMemberToJson(this);
}

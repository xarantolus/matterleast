// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_notify_props.g.dart';

@JsonSerializable()
class ChannelNotifyProps {
  const ChannelNotifyProps({
    this.email,
    this.push,
    this.desktop,
    this.markUnread,
    this.ignoreChannelMentions,
    this.desktopThreads,
    this.pushThreads,
    this.emailThreads,
    this.channelAutoFollowThreads,
  });

  factory ChannelNotifyProps.fromJson(Map<String, Object?> json) =>
      _$ChannelNotifyPropsFromJson(json);

  @LenientString()
  final String? email;

  @LenientString()
  final String? push;

  @LenientString()
  final String? desktop;

  @LenientString()
  @JsonKey(name: 'mark_unread')
  final String? markUnread;
  @LenientString()
  @JsonKey(name: 'ignore_channel_mentions')
  final String? ignoreChannelMentions;
  @LenientString()
  @JsonKey(name: 'desktop_threads')
  final String? desktopThreads;
  @LenientString()
  @JsonKey(name: 'push_threads')
  final String? pushThreads;
  @LenientString()
  @JsonKey(name: 'email_threads')
  final String? emailThreads;
  @LenientString()
  @JsonKey(name: 'channel_auto_follow_threads')
  final String? channelAutoFollowThreads;

  Map<String, Object?> toJson() => _$ChannelNotifyPropsToJson(this);
}

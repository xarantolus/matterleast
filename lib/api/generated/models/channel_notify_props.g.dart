// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_notify_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelNotifyProps _$ChannelNotifyPropsFromJson(Map<String, dynamic> json) =>
    ChannelNotifyProps(
      email: const LenientString().fromJson(json['email']),
      push: const LenientString().fromJson(json['push']),
      desktop: const LenientString().fromJson(json['desktop']),
      markUnread: const LenientString().fromJson(json['mark_unread']),
      ignoreChannelMentions: const LenientString().fromJson(
        json['ignore_channel_mentions'],
      ),
      desktopThreads: const LenientString().fromJson(json['desktop_threads']),
      pushThreads: const LenientString().fromJson(json['push_threads']),
      emailThreads: const LenientString().fromJson(json['email_threads']),
      channelAutoFollowThreads: const LenientString().fromJson(
        json['channel_auto_follow_threads'],
      ),
    );

Map<String, dynamic> _$ChannelNotifyPropsToJson(ChannelNotifyProps instance) =>
    <String, dynamic>{
      'email': const LenientString().toJson(instance.email),
      'push': const LenientString().toJson(instance.push),
      'desktop': const LenientString().toJson(instance.desktop),
      'mark_unread': const LenientString().toJson(instance.markUnread),
      'ignore_channel_mentions': const LenientString().toJson(
        instance.ignoreChannelMentions,
      ),
      'desktop_threads': const LenientString().toJson(instance.desktopThreads),
      'push_threads': const LenientString().toJson(instance.pushThreads),
      'email_threads': const LenientString().toJson(instance.emailThreads),
      'channel_auto_follow_threads': const LenientString().toJson(
        instance.channelAutoFollowThreads,
      ),
    };

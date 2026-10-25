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
    );

Map<String, dynamic> _$ChannelNotifyPropsToJson(ChannelNotifyProps instance) =>
    <String, dynamic>{
      'email': const LenientString().toJson(instance.email),
      'push': const LenientString().toJson(instance.push),
      'desktop': const LenientString().toJson(instance.desktop),
      'mark_unread': const LenientString().toJson(instance.markUnread),
    };

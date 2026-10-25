// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notify_props.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotifyProps _$UserNotifyPropsFromJson(Map<String, dynamic> json) =>
    UserNotifyProps(
      email: const LenientString().fromJson(json['email']),
      push: const LenientString().fromJson(json['push']),
      desktop: const LenientString().fromJson(json['desktop']),
      desktopSound: const LenientString().fromJson(json['desktop_sound']),
      mentionKeys: const LenientString().fromJson(json['mention_keys']),
      channel: const LenientString().fromJson(json['channel']),
      firstName: const LenientString().fromJson(json['first_name']),
      autoResponderMessage: const LenientString().fromJson(
        json['auto_responder_message'],
      ),
      pushThreads: const LenientString().fromJson(json['push_threads']),
      comments: const LenientString().fromJson(json['comments']),
      desktopThreads: const LenientString().fromJson(json['desktop_threads']),
      emailThreads: const LenientString().fromJson(json['email_threads']),
    );

Map<String, dynamic> _$UserNotifyPropsToJson(UserNotifyProps instance) =>
    <String, dynamic>{
      'email': const LenientString().toJson(instance.email),
      'push': const LenientString().toJson(instance.push),
      'desktop': const LenientString().toJson(instance.desktop),
      'desktop_sound': const LenientString().toJson(instance.desktopSound),
      'mention_keys': const LenientString().toJson(instance.mentionKeys),
      'channel': const LenientString().toJson(instance.channel),
      'first_name': const LenientString().toJson(instance.firstName),
      'auto_responder_message': const LenientString().toJson(
        instance.autoResponderMessage,
      ),
      'push_threads': const LenientString().toJson(instance.pushThreads),
      'comments': const LenientString().toJson(instance.comments),
      'desktop_threads': const LenientString().toJson(instance.desktopThreads),
      'email_threads': const LenientString().toJson(instance.emailThreads),
    };

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'user_notify_props.g.dart';

@JsonSerializable()
class UserNotifyProps {
  const UserNotifyProps({
    this.email,
    this.push,
    this.desktop,
    this.desktopSound,
    this.mentionKeys,
    this.channel,
    this.firstName,
    this.autoResponderMessage,
    this.pushThreads,
    this.comments,
    this.desktopThreads,
    this.emailThreads,
  });

  factory UserNotifyProps.fromJson(Map<String, Object?> json) =>
      _$UserNotifyPropsFromJson(json);

  @LenientString()
  final String? email;

  @LenientString()
  final String? push;

  @LenientString()
  final String? desktop;

  @LenientString()
  @JsonKey(name: 'desktop_sound')
  final String? desktopSound;

  @LenientString()
  @JsonKey(name: 'mention_keys')
  final String? mentionKeys;

  @LenientString()
  final String? channel;

  @LenientString()
  @JsonKey(name: 'first_name')
  final String? firstName;

  @LenientString()
  @JsonKey(name: 'auto_responder_message')
  final String? autoResponderMessage;

  @LenientString()
  @JsonKey(name: 'push_threads')
  final String? pushThreads;

  @LenientString()
  final String? comments;

  @LenientString()
  @JsonKey(name: 'desktop_threads')
  final String? desktopThreads;

  @LenientString()
  @JsonKey(name: 'email_threads')
  final String? emailThreads;

  Map<String, Object?> toJson() => _$UserNotifyPropsToJson(this);
}

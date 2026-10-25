// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'timezone.dart';
import 'user_notify_props.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
    this.id,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.username,
    this.firstName,
    this.lastName,
    this.nickname,
    this.email,
    this.emailVerified,
    this.authService,
    this.roles,
    this.locale,
    this.notifyProps,
    this.props,
    this.lastPasswordUpdate,
    this.lastPictureUpdate,
    this.failedAttempts,
    this.mfaActive,
    this.timezone,
    this.termsOfServiceId,
    this.termsOfServiceCreateAt,
    this.isBot,
    this.botDescription,
    this.botLastIconUpdate,
    this.lastActivityAt,
    this.position,
    this.remoteId,
  });

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  @LenientString()
  final String? id;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;

  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  final String? username;
  @LenientString()
  @JsonKey(name: 'first_name')
  final String? firstName;
  @LenientString()
  @JsonKey(name: 'last_name')
  final String? lastName;
  @LenientString()
  final String? nickname;
  @LenientString()
  final String? email;
  @LenientBool()
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @LenientString()
  @JsonKey(name: 'auth_service')
  final String? authService;
  @LenientString()
  final String? roles;
  @LenientString()
  final String? locale;
  @LenientUserNotifyProps()
  @JsonKey(name: 'notify_props')
  final UserNotifyProps? notifyProps;
  @JsonMap()
  final Map<String, Object?>? props;
  @MillisDateTime()
  @JsonKey(name: 'last_password_update')
  final DateTime? lastPasswordUpdate;
  @MillisDateTime()
  @JsonKey(name: 'last_picture_update')
  final DateTime? lastPictureUpdate;
  @LenientInt()
  @JsonKey(name: 'failed_attempts')
  final int? failedAttempts;
  @LenientBool()
  @JsonKey(name: 'mfa_active')
  final bool? mfaActive;
  @LenientTimezone()
  final Timezone? timezone;

  @LenientString()
  @JsonKey(name: 'terms_of_service_id')
  final String? termsOfServiceId;

  @MillisDateTime()
  @JsonKey(name: 'terms_of_service_create_at')
  final DateTime? termsOfServiceCreateAt;
  @LenientBool()
  @JsonKey(name: 'is_bot')
  final bool? isBot;
  @LenientString()
  @JsonKey(name: 'bot_description')
  final String? botDescription;
  @MillisDateTime()
  @JsonKey(name: 'bot_last_icon_update')
  final DateTime? botLastIconUpdate;
  @MillisDateTime()
  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;
  @LenientString()
  final String? position;
  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;

  Map<String, Object?> toJson() => _$UserToJson(this);
}

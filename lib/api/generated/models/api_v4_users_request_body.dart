// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'timezone.dart';
import 'user_notify_props.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'api_v4_users_request_body.g.dart';

@JsonSerializable()
class ApiV4UsersRequestBody {
  const ApiV4UsersRequestBody({
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.nickname,
    this.position,
    this.timezone,
    this.authData,
    this.authService,
    this.password,
    this.locale,
    this.props,
    this.notifyProps,
  });

  factory ApiV4UsersRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4UsersRequestBodyFromJson(json);

  final String email;
  final String username;
  @LenientString()
  @JsonKey(name: 'first_name')
  final String? firstName;
  @LenientString()
  @JsonKey(name: 'last_name')
  final String? lastName;
  @LenientString()
  final String? nickname;
  @LenientString()
  final String? position;
  @LenientTimezone()
  final Timezone? timezone;
  @LenientString()
  @JsonKey(name: 'auth_data')
  final String? authData;
  @LenientString()
  @JsonKey(name: 'auth_service')
  final String? authService;
  @LenientString()
  final String? password;
  @LenientString()
  final String? locale;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientUserNotifyProps()
  @JsonKey(name: 'notify_props')
  final UserNotifyProps? notifyProps;

  Map<String, Object?> toJson() => _$ApiV4UsersRequestBodyToJson(this);
}

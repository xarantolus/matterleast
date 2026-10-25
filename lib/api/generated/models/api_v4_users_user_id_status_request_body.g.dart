// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_users_user_id_status_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4UsersUserIdStatusRequestBody _$ApiV4UsersUserIdStatusRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4UsersUserIdStatusRequestBody(
  userId: json['user_id'] as String,
  status: json['status'] as String,
  dndEndTime: const LenientInt().fromJson(json['dnd_end_time']),
);

Map<String, dynamic> _$ApiV4UsersUserIdStatusRequestBodyToJson(
  ApiV4UsersUserIdStatusRequestBody instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'status': instance.status,
  'dnd_end_time': const LenientInt().toJson(instance.dndEndTime),
};

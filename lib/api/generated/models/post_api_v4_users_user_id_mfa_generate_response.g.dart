// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_users_user_id_mfa_generate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4UsersUserIdMfaGenerateResponse
_$PostApiV4UsersUserIdMfaGenerateResponseFromJson(Map<String, dynamic> json) =>
    PostApiV4UsersUserIdMfaGenerateResponse(
      secret: const LenientString().fromJson(json['secret']),
      qrCode: const LenientString().fromJson(json['qr_code']),
    );

Map<String, dynamic> _$PostApiV4UsersUserIdMfaGenerateResponseToJson(
  PostApiV4UsersUserIdMfaGenerateResponse instance,
) => <String, dynamic>{
  'secret': const LenientString().toJson(instance.secret),
  'qr_code': const LenientString().toJson(instance.qrCode),
};

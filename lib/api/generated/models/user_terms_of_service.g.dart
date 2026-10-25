// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_terms_of_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTermsOfService _$UserTermsOfServiceFromJson(Map<String, dynamic> json) =>
    UserTermsOfService(
      userId: const LenientString().fromJson(json['user_id']),
      termsOfServiceId: const LenientString().fromJson(
        json['terms_of_service_id'],
      ),
      createAt: const MillisDateTime().fromJson(json['create_at']),
    );

Map<String, dynamic> _$UserTermsOfServiceToJson(UserTermsOfService instance) =>
    <String, dynamic>{
      'user_id': const LenientString().toJson(instance.userId),
      'terms_of_service_id': const LenientString().toJson(
        instance.termsOfServiceId,
      ),
      'create_at': const MillisDateTime().toJson(instance.createAt),
    };

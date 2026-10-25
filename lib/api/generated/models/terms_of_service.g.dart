// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_of_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermsOfService _$TermsOfServiceFromJson(Map<String, dynamic> json) =>
    TermsOfService(
      id: const LenientString().fromJson(json['id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      userId: const LenientString().fromJson(json['user_id']),
      text: const LenientString().fromJson(json['text']),
    );

Map<String, dynamic> _$TermsOfServiceToJson(TermsOfService instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'user_id': const LenientString().toJson(instance.userId),
      'text': const LenientString().toJson(instance.text),
    };

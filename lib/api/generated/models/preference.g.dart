// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Preference _$PreferenceFromJson(Map<String, dynamic> json) => Preference(
  userId: const LenientString().fromJson(json['user_id']),
  category: const LenientString().fromJson(json['category']),
  name: const LenientString().fromJson(json['name']),
  value: const LenientString().fromJson(json['value']),
);

Map<String, dynamic> _$PreferenceToJson(Preference instance) =>
    <String, dynamic>{
      'user_id': const LenientString().toJson(instance.userId),
      'category': const LenientString().toJson(instance.category),
      'name': const LenientString().toJson(instance.name),
      'value': const LenientString().toJson(instance.value),
    };

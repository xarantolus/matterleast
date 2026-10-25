// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timezone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timezone _$TimezoneFromJson(Map<String, dynamic> json) => Timezone(
  useAutomaticTimezone: const LenientString().fromJson(
    json['useAutomaticTimezone'],
  ),
  manualTimezone: const LenientString().fromJson(json['manualTimezone']),
  automaticTimezone: const LenientString().fromJson(json['automaticTimezone']),
);

Map<String, dynamic> _$TimezoneToJson(Timezone instance) => <String, dynamic>{
  'useAutomaticTimezone': const LenientString().toJson(
    instance.useAutomaticTimezone,
  ),
  'manualTimezone': const LenientString().toJson(instance.manualTimezone),
  'automaticTimezone': const LenientString().toJson(instance.automaticTimezone),
};

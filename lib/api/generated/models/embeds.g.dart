// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embeds.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Embeds _$EmbedsFromJson(Map<String, dynamic> json) => Embeds(
  type: json['type'] == null ? null : Type2.fromJson(json['type'] as String),
  url: const LenientString().fromJson(json['url']),
  data: const JsonMap().fromJson(json['data']),
);

Map<String, dynamic> _$EmbedsToJson(Embeds instance) => <String, dynamic>{
  'type': instance.type,
  'url': const LenientString().toJson(instance.url),
  'data': const JsonMap().toJson(instance.data),
};

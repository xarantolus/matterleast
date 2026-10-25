// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_posts_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PostsSearchRequestBody _$ApiV4PostsSearchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PostsSearchRequestBody(
  terms: json['terms'] as String,
  isOrSearch: const LenientBool().fromJson(json['is_or_search']),
  timeZoneOffset: const LenientInt().fromJson(json['time_zone_offset']),
  includeDeletedChannels: const LenientBool().fromJson(
    json['include_deleted_channels'],
  ),
  page: const LenientInt().fromJson(json['page']),
  perPage: const LenientInt().fromJson(json['per_page']),
);

Map<String, dynamic> _$ApiV4PostsSearchRequestBodyToJson(
  ApiV4PostsSearchRequestBody instance,
) => <String, dynamic>{
  'terms': instance.terms,
  'is_or_search': const LenientBool().toJson(instance.isOrSearch),
  'time_zone_offset': const LenientInt().toJson(instance.timeZoneOffset),
  'include_deleted_channels': const LenientBool().toJson(
    instance.includeDeletedChannels,
  ),
  'page': const LenientInt().toJson(instance.page),
  'per_page': const LenientInt().toJson(instance.perPage),
};

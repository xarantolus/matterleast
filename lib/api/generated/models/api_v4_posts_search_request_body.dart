// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_posts_search_request_body.g.dart';

@JsonSerializable()
class ApiV4PostsSearchRequestBody {
  const ApiV4PostsSearchRequestBody({
    required this.terms,
    this.isOrSearch,
    this.timeZoneOffset,
    this.includeDeletedChannels,
    this.page,
    this.perPage,
  });

  factory ApiV4PostsSearchRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4PostsSearchRequestBodyFromJson(json);

  final String terms;
  @LenientBool()
  @JsonKey(name: 'is_or_search')
  final bool? isOrSearch;
  @LenientInt()
  @JsonKey(name: 'time_zone_offset')
  final int? timeZoneOffset;
  @LenientBool()
  @JsonKey(name: 'include_deleted_channels')
  final bool? includeDeletedChannels;
  @LenientInt()
  final int? page;
  @LenientInt()
  @JsonKey(name: 'per_page')
  final int? perPage;

  Map<String, Object?> toJson() => _$ApiV4PostsSearchRequestBodyToJson(this);
}

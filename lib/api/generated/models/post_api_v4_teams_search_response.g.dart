// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_teams_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4TeamsSearchResponse _$PostApiV4TeamsSearchResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4TeamsSearchResponse(
  totalCount: json['total_count'] as num?,
  teams: json['teams'] == null
      ? const []
      : const LenientListOfTeam().fromJson(json['teams']),
);

Map<String, dynamic> _$PostApiV4TeamsSearchResponseToJson(
  PostApiV4TeamsSearchResponse instance,
) => <String, dynamic>{
  'teams': const LenientListOfTeam().toJson(instance.teams),
  'total_count': instance.totalCount,
};

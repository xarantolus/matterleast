// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_team_id_files_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsTeamIdFilesSearchRequestBody
_$ApiV4TeamsTeamIdFilesSearchRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4TeamsTeamIdFilesSearchRequestBody(
      terms: json['terms'] as String,
      isOrSearch: json['is_or_search'] as bool,
      includeDeletedChannels: const LenientBool().fromJson(
        json['include_deleted_channels'],
      ),
      timeZoneOffset: (json['time_zone_offset'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 0,
      perPage: (json['per_page'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$ApiV4TeamsTeamIdFilesSearchRequestBodyToJson(
  ApiV4TeamsTeamIdFilesSearchRequestBody instance,
) => <String, dynamic>{
  'terms': instance.terms,
  'is_or_search': instance.isOrSearch,
  'time_zone_offset': instance.timeZoneOffset,
  'include_deleted_channels': const LenientBool().toJson(
    instance.includeDeletedChannels,
  ),
  'page': instance.page,
  'per_page': instance.perPage,
};

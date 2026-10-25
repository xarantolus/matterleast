// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_teams_team_id_files_search_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdFilesSearchRequestBody {
  const ApiV4TeamsTeamIdFilesSearchRequestBody({
    required this.terms,
    required this.isOrSearch,
    this.includeDeletedChannels,
    this.timeZoneOffset = 0,
    this.page = 0,
    this.perPage = 60,
  });

  factory ApiV4TeamsTeamIdFilesSearchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4TeamsTeamIdFilesSearchRequestBodyFromJson(json);

  final String terms;
  @JsonKey(name: 'is_or_search')
  final bool isOrSearch;
  @JsonKey(name: 'time_zone_offset')
  final int timeZoneOffset;
  @LenientBool()
  @JsonKey(name: 'include_deleted_channels')
  final bool? includeDeletedChannels;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;

  Map<String, Object?> toJson() =>
      _$ApiV4TeamsTeamIdFilesSearchRequestBodyToJson(this);
}

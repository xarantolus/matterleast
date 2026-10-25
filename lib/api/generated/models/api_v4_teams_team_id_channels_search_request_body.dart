// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_teams_team_id_channels_search_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsTeamIdChannelsSearchRequestBody {
  const ApiV4TeamsTeamIdChannelsSearchRequestBody({required this.term});

  factory ApiV4TeamsTeamIdChannelsSearchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4TeamsTeamIdChannelsSearchRequestBodyFromJson(json);

  final String term;

  Map<String, Object?> toJson() =>
      _$ApiV4TeamsTeamIdChannelsSearchRequestBodyToJson(this);
}

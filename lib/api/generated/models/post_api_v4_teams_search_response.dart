// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'team.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_api_v4_teams_search_response.g.dart';

@JsonSerializable()
class PostApiV4TeamsSearchResponse {
  const PostApiV4TeamsSearchResponse({this.totalCount, this.teams = const []});

  factory PostApiV4TeamsSearchResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV4TeamsSearchResponseFromJson(json);

  @LenientListOfTeam()
  final List<Team> teams;
  @LenientDouble()
  @JsonKey(name: 'total_count')
  final num? totalCount;

  Map<String, Object?> toJson() => _$PostApiV4TeamsSearchResponseToJson(this);
}

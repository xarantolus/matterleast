// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'team_stats.g.dart';

@JsonSerializable()
class TeamStats {
  const TeamStats({this.teamId, this.totalMemberCount});

  factory TeamStats.fromJson(Map<String, Object?> json) =>
      _$TeamStatsFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientInt()
  @JsonKey(name: 'total_member_count')
  final int? totalMemberCount;

  Map<String, Object?> toJson() => _$TeamStatsToJson(this);
}

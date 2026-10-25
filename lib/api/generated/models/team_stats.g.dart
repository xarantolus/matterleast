// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamStats _$TeamStatsFromJson(Map<String, dynamic> json) => TeamStats(
  teamId: const LenientString().fromJson(json['team_id']),
  totalMemberCount: const LenientInt().fromJson(json['total_member_count']),
);

Map<String, dynamic> _$TeamStatsToJson(TeamStats instance) => <String, dynamic>{
  'team_id': const LenientString().toJson(instance.teamId),
  'total_member_count': const LenientInt().toJson(instance.totalMemberCount),
};

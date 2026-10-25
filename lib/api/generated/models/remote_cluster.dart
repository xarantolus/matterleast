// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'remote_cluster.g.dart';

@JsonSerializable()
class RemoteCluster {
  const RemoteCluster({
    this.remoteId,
    this.remoteTeamId,
    this.name,
    this.displayName,
    this.siteUrl,
    this.defaultTeamId,
    this.createAt,
    this.deleteAt,
    this.lastPingAt,
    this.token,
    this.remoteToken,
    this.topics,
    this.creatorId,
    this.pluginId,
    this.options,
  });

  factory RemoteCluster.fromJson(Map<String, Object?> json) =>
      _$RemoteClusterFromJson(json);

  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;
  @LenientString()
  @JsonKey(name: 'remote_team_id')
  final String? remoteTeamId;
  @LenientString()
  final String? name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  @LenientString()
  @JsonKey(name: 'site_url')
  final String? siteUrl;

  @LenientString()
  @JsonKey(name: 'default_team_id')
  final String? defaultTeamId;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;

  @MillisDateTime()
  @JsonKey(name: 'last_ping_at')
  final DateTime? lastPingAt;
  @LenientString()
  final String? token;
  @LenientString()
  @JsonKey(name: 'remote_token')
  final String? remoteToken;
  @LenientString()
  final String? topics;
  @LenientString()
  @JsonKey(name: 'creator_id')
  final String? creatorId;
  @LenientString()
  @JsonKey(name: 'plugin_id')
  final String? pluginId;

  @LenientInt()
  final int? options;

  Map<String, Object?> toJson() => _$RemoteClusterToJson(this);
}

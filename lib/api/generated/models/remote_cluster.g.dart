// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_cluster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteCluster _$RemoteClusterFromJson(Map<String, dynamic> json) =>
    RemoteCluster(
      remoteId: const LenientString().fromJson(json['remote_id']),
      remoteTeamId: const LenientString().fromJson(json['remote_team_id']),
      name: const LenientString().fromJson(json['name']),
      displayName: const LenientString().fromJson(json['display_name']),
      siteUrl: const LenientString().fromJson(json['site_url']),
      defaultTeamId: const LenientString().fromJson(json['default_team_id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      deleteAt: const MillisDateTime().fromJson(json['delete_at']),
      lastPingAt: const MillisDateTime().fromJson(json['last_ping_at']),
      token: const LenientString().fromJson(json['token']),
      remoteToken: const LenientString().fromJson(json['remote_token']),
      topics: const LenientString().fromJson(json['topics']),
      creatorId: const LenientString().fromJson(json['creator_id']),
      pluginId: const LenientString().fromJson(json['plugin_id']),
      options: const LenientInt().fromJson(json['options']),
    );

Map<String, dynamic> _$RemoteClusterToJson(RemoteCluster instance) =>
    <String, dynamic>{
      'remote_id': const LenientString().toJson(instance.remoteId),
      'remote_team_id': const LenientString().toJson(instance.remoteTeamId),
      'name': const LenientString().toJson(instance.name),
      'display_name': const LenientString().toJson(instance.displayName),
      'site_url': const LenientString().toJson(instance.siteUrl),
      'default_team_id': const LenientString().toJson(instance.defaultTeamId),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'delete_at': const MillisDateTime().toJson(instance.deleteAt),
      'last_ping_at': const MillisDateTime().toJson(instance.lastPingAt),
      'token': const LenientString().toJson(instance.token),
      'remote_token': const LenientString().toJson(instance.remoteToken),
      'topics': const LenientString().toJson(instance.topics),
      'creator_id': const LenientString().toJson(instance.creatorId),
      'plugin_id': const LenientString().toJson(instance.pluginId),
      'options': const LenientInt().toJson(instance.options),
    };

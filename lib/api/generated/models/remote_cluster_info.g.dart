// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_cluster_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteClusterInfo _$RemoteClusterInfoFromJson(Map<String, dynamic> json) =>
    RemoteClusterInfo(
      displayName: const LenientString().fromJson(json['display_name']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      lastPingAt: const MillisDateTime().fromJson(json['last_ping_at']),
    );

Map<String, dynamic> _$RemoteClusterInfoToJson(RemoteClusterInfo instance) =>
    <String, dynamic>{
      'display_name': const LenientString().toJson(instance.displayName),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'last_ping_at': const MillisDateTime().toJson(instance.lastPingAt),
    };

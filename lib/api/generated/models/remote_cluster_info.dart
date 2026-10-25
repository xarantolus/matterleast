// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'remote_cluster_info.g.dart';

@JsonSerializable()
class RemoteClusterInfo {
  const RemoteClusterInfo({this.displayName, this.createAt, this.lastPingAt});

  factory RemoteClusterInfo.fromJson(Map<String, Object?> json) =>
      _$RemoteClusterInfoFromJson(json);

  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'last_ping_at')
  final DateTime? lastPingAt;

  Map<String, Object?> toJson() => _$RemoteClusterInfoToJson(this);
}

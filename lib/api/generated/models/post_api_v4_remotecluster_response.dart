// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'remote_cluster.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_api_v4_remotecluster_response.g.dart';

@JsonSerializable()
class PostApiV4RemoteclusterResponse {
  const PostApiV4RemoteclusterResponse({
    this.remoteCluster,
    this.invite,
    this.password,
  });

  factory PostApiV4RemoteclusterResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV4RemoteclusterResponseFromJson(json);

  @LenientRemoteCluster()
  @JsonKey(name: 'remote_cluster')
  final RemoteCluster? remoteCluster;
  @LenientString()
  final String? invite;
  @LenientString()
  final String? password;

  Map<String, Object?> toJson() => _$PostApiV4RemoteclusterResponseToJson(this);
}

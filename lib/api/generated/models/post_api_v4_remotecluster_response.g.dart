// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_remotecluster_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4RemoteclusterResponse _$PostApiV4RemoteclusterResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV4RemoteclusterResponse(
  remoteCluster: const LenientRemoteCluster().fromJson(json['remote_cluster']),
  invite: const LenientString().fromJson(json['invite']),
  password: const LenientString().fromJson(json['password']),
);

Map<String, dynamic> _$PostApiV4RemoteclusterResponseToJson(
  PostApiV4RemoteclusterResponse instance,
) => <String, dynamic>{
  'remote_cluster': const LenientRemoteCluster().toJson(instance.remoteCluster),
  'invite': const LenientString().toJson(instance.invite),
  'password': const LenientString().toJson(instance.password),
};

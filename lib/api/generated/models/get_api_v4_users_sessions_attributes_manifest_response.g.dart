// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v4_users_sessions_attributes_manifest_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV4UsersSessionsAttributesManifestResponse
_$GetApiV4UsersSessionsAttributesManifestResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV4UsersSessionsAttributesManifestResponse(
  platforms: json['platforms'] == null
      ? const []
      : const LenientStringList().fromJson(json['platforms']),
  name: const LenientString().fromJson(json['name']),
  type: const LenientString().fromJson(json['type']),
  ttlSeconds: const LenientInt().fromJson(json['ttl_seconds']),
  gracePeriodSeconds: const LenientInt().fromJson(json['grace_period_seconds']),
  displayName: const LenientString().fromJson(json['display_name']),
);

Map<String, dynamic> _$GetApiV4UsersSessionsAttributesManifestResponseToJson(
  GetApiV4UsersSessionsAttributesManifestResponse instance,
) => <String, dynamic>{
  'name': const LenientString().toJson(instance.name),
  'type': const LenientString().toJson(instance.type),
  'ttl_seconds': const LenientInt().toJson(instance.ttlSeconds),
  'grace_period_seconds': const LenientInt().toJson(
    instance.gracePeriodSeconds,
  ),
  'platforms': const LenientStringList().toJson(instance.platforms),
  'display_name': const LenientString().toJson(instance.displayName),
};

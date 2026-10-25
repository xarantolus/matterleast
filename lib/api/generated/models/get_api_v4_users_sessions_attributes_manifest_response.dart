// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_users_sessions_attributes_manifest_response.g.dart';

@JsonSerializable()
class GetApiV4UsersSessionsAttributesManifestResponse {
  const GetApiV4UsersSessionsAttributesManifestResponse({
    this.platforms = const [],
    this.name,
    this.type,
    this.ttlSeconds,
    this.gracePeriodSeconds,
    this.displayName,
  });

  factory GetApiV4UsersSessionsAttributesManifestResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV4UsersSessionsAttributesManifestResponseFromJson(json);

  @LenientString()
  final String? name;
  @LenientString()
  final String? type;
  @LenientInt()
  @JsonKey(name: 'ttl_seconds')
  final int? ttlSeconds;
  @LenientInt()
  @JsonKey(name: 'grace_period_seconds')
  final int? gracePeriodSeconds;
  @LenientStringList()
  final List<String> platforms;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  Map<String, Object?> toJson() =>
      _$GetApiV4UsersSessionsAttributesManifestResponseToJson(this);
}

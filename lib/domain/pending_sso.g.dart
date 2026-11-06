// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sso.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingSso _$PendingSsoFromJson(Map<String, dynamic> json) => _PendingSso(
  serverUrl: json['serverUrl'] as String,
  displayName: json['displayName'] as String,
  state: json['state'] as String,
  verifier: json['verifier'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  ssoScheme: json['ssoScheme'] as String?,
  replaces: json['replaces'] as String?,
);

Map<String, dynamic> _$PendingSsoToJson(_PendingSso instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'displayName': instance.displayName,
      'state': instance.state,
      'verifier': instance.verifier,
      'startedAt': instance.startedAt.toIso8601String(),
      'ssoScheme': instance.ssoScheme,
      'replaces': instance.replaces,
    };

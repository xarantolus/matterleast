// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileServer _$FileServerFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'url',
      'displayName',
      'sortOrder',
      'themeMode',
      'ssoScheme',
    ],
  );
  return FileServer(
    url: json['url'] as String,
    displayName: json['displayName'] as String,
    sortOrder: (json['sortOrder'] as num).toInt(),
    themeMode: json['themeMode'] as String,
    ssoScheme: json['ssoScheme'] as String?,
  );
}

Map<String, dynamic> _$FileServerToJson(FileServer instance) =>
    <String, dynamic>{
      'url': instance.url,
      'displayName': instance.displayName,
      'sortOrder': instance.sortOrder,
      'themeMode': instance.themeMode,
      'ssoScheme': instance.ssoScheme,
    };

SettingsFile _$SettingsFileFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['version', 'servers', 'settings', 'stayConnected'],
  );
  return SettingsFile(
    version: (json['version'] as num).toInt(),
    servers: (json['servers'] as List<dynamic>)
        .map((e) => FileServer.fromJson(e as Map<String, dynamic>))
        .toList(),
    settings: Map<String, String>.from(json['settings'] as Map),
    stayConnected: json['stayConnected'] as bool?,
  );
}

Map<String, dynamic> _$SettingsFileToJson(SettingsFile instance) =>
    <String, dynamic>{
      'version': instance.version,
      'servers': instance.servers,
      'settings': instance.settings,
      'stayConnected': instance.stayConnected,
    };

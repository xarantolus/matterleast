// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_manifest_webapp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginManifestWebapp _$PluginManifestWebappFromJson(
  Map<String, dynamic> json,
) => PluginManifestWebapp(
  id: const LenientString().fromJson(json['id']),
  version: const LenientString().fromJson(json['version']),
  webapp: const LenientWebapp2().fromJson(json['webapp']),
);

Map<String, dynamic> _$PluginManifestWebappToJson(
  PluginManifestWebapp instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'version': const LenientString().toJson(instance.version),
  'webapp': const LenientWebapp2().toJson(instance.webapp),
};

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'webapp2.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'plugin_manifest_webapp.g.dart';

@JsonSerializable()
class PluginManifestWebapp {
  const PluginManifestWebapp({this.id, this.version, this.webapp});

  factory PluginManifestWebapp.fromJson(Map<String, Object?> json) =>
      _$PluginManifestWebappFromJson(json);

  @LenientString()
  final String? id;

  @LenientString()
  final String? version;
  @LenientWebapp2()
  final Webapp2? webapp;

  Map<String, Object?> toJson() => _$PluginManifestWebappToJson(this);
}

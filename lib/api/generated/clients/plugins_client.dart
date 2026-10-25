// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/plugin_manifest_webapp.dart';

part 'plugins_client.g.dart';

@RestApi()
abstract class PluginsClient {
  factory PluginsClient(Dio dio, {String? baseUrl}) = _PluginsClient;

  @GET('/api/v4/plugins/webapp')
  Future<List<PluginManifestWebapp>> getWebappPlugins();
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_ephemeral_mode_cleanup_request_body.dart';
import '../models/api_v4_ephemeral_mode_purge_request_body.dart';
import '../models/api_v4_ephemeral_mode_wipe_request_body.dart';
import '../models/status_ok.dart';

part 'ephemeral_mode_client.g.dart';

@RestApi()
abstract class EphemeralModeClient {
  factory EphemeralModeClient(Dio dio, {String? baseUrl}) =
      _EphemeralModeClient;

  @POST('/api/v4/ephemeral_mode/cleanup')
  Future<StatusOk> logCleanup({
    @Body() required ApiV4EphemeralModeCleanupRequestBody body,
  });

  @POST('/api/v4/ephemeral_mode/purge')
  Future<StatusOk> logOfflinePurge({
    @Body() required ApiV4EphemeralModePurgeRequestBody body,
  });

  @POST('/api/v4/ephemeral_mode/wipe')
  Future<StatusOk> logSessionWipe({
    @Body() required ApiV4EphemeralModeWipeRequestBody body,
  });
}

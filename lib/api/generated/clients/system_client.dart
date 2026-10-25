// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v4_license_load_metric_response.dart';
import '../models/status_ok.dart';

part 'system_client.g.dart';

@RestApi()
abstract class SystemClient {
  factory SystemClient(Dio dio, {String? baseUrl}) = _SystemClient;

  @GET('/api/v4/system/timezones')
  Future<List<String>> getSupportedTimezone();

  @POST('/api/v4/notifications/test')
  Future<StatusOk> testNotification();

  @GET('/api/v4/config/client')
  Future<void> getClientConfig();

  @GET('/api/v4/license/client')
  Future<void> getClientLicense();

  @GET('/api/v4/license/load_metric')
  Future<GetApiV4LicenseLoadMetricResponse> getLicenseLoadMetric();
}

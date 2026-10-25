// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_license_load_metric_response.g.dart';

@JsonSerializable()
class GetApiV4LicenseLoadMetricResponse {
  const GetApiV4LicenseLoadMetricResponse({this.load});

  factory GetApiV4LicenseLoadMetricResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV4LicenseLoadMetricResponseFromJson(json);

  @LenientInt()
  final int? load;

  Map<String, Object?> toJson() =>
      _$GetApiV4LicenseLoadMetricResponseToJson(this);
}

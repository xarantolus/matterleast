// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/terms_of_service.dart';

part 'terms_of_service_client.g.dart';

@RestApi()
abstract class TermsOfServiceClient {
  factory TermsOfServiceClient(Dio dio, {String? baseUrl}) =
      _TermsOfServiceClient;

  @GET('/api/v4/terms_of_service')
  Future<TermsOfService> getTermsOfService();

  @POST('/api/v4/terms_of_service')
  Future<TermsOfService> createTermsOfService();
}

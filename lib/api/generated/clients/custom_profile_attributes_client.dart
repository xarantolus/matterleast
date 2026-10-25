// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_custom_profile_attributes_fields_request_body.dart';
import '../models/api_v4_custom_profile_attributes_values_request_body.dart';
import '../models/api_v4_users_user_id_custom_profile_attributes_request_body.dart';
import '../models/patch_api_v4_custom_profile_attributes_values_response.dart';
import '../models/patch_api_v4_users_user_id_custom_profile_attributes_response.dart';
import '../models/property_field.dart';

part 'custom_profile_attributes_client.g.dart';

@RestApi()
abstract class CustomProfileAttributesClient {
  factory CustomProfileAttributesClient(Dio dio, {String? baseUrl}) =
      _CustomProfileAttributesClient;

  @GET('/api/v4/custom_profile_attributes/fields')
  Future<List<PropertyField>> listAllCpaFields();

  @POST('/api/v4/custom_profile_attributes/fields')
  Future<PropertyField> createCpaField({
    @Body() ApiV4CustomProfileAttributesFieldsRequestBody? body,
  });

  @PATCH('/api/v4/custom_profile_attributes/values')
  Future<List<PatchApiV4CustomProfileAttributesValuesResponse>> patchCpaValues({
    @Body() required List<ApiV4CustomProfileAttributesValuesRequestBody> body,
  });

  @GET('/api/v4/users/{user_id}/custom_profile_attributes')
  Future<Map<String, String>> listCpaValues({
    @Path('user_id') required String userId,
  });

  @PATCH('/api/v4/users/{user_id}/custom_profile_attributes')
  Future<List<PatchApiV4UsersUserIdCustomProfileAttributesResponse>>
  patchCpaValuesForUser({
    @Path('user_id') required String userId,
    @Body()
    required List<ApiV4UsersUserIdCustomProfileAttributesRequestBody> body,
  });
}

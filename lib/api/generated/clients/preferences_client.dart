// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/preference.dart';
import '../models/status_ok.dart';

part 'preferences_client.g.dart';

@RestApi()
abstract class PreferencesClient {
  factory PreferencesClient(Dio dio, {String? baseUrl}) = _PreferencesClient;

  @GET('/api/v4/users/{user_id}/preferences')
  Future<List<Preference>> getPreferences({
    @Path('user_id') required String userId,
  });

  @PUT('/api/v4/users/{user_id}/preferences')
  Future<StatusOk> updatePreferences({
    @Path('user_id') required String userId,
    @Body() required List<Preference> body,
  });

  @POST('/api/v4/users/{user_id}/preferences/delete')
  Future<StatusOk> deletePreferences({
    @Path('user_id') required String userId,
    @Body() required List<Preference> body,
  });
}

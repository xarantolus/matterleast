// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_actions_dialogs_lookup_request_body.dart';
import '../models/api_v4_actions_dialogs_submit_request_body.dart';
import '../models/post_api_v4_actions_dialogs_lookup_response.dart';
import '../models/status_ok.dart';

part 'integration_actions_client.g.dart';

@RestApi()
abstract class IntegrationActionsClient {
  factory IntegrationActionsClient(Dio dio, {String? baseUrl}) =
      _IntegrationActionsClient;

  @POST('/api/v4/actions/dialogs/submit')
  Future<StatusOk> submitInteractiveDialog({
    @Body() required ApiV4ActionsDialogsSubmitRequestBody body,
  });

  @POST('/api/v4/actions/dialogs/lookup')
  Future<PostApiV4ActionsDialogsLookupResponse> lookupInteractiveDialog({
    @Body() required ApiV4ActionsDialogsLookupRequestBody body,
  });
}

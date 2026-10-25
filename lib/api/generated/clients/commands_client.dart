// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_commands_execute_request_body.dart';
import '../models/api_v4_commands_request_body.dart';
import '../models/autocomplete_suggestion.dart';
import '../models/command.dart';
import '../models/command_response.dart';

part 'commands_client.g.dart';

@RestApi()
abstract class CommandsClient {
  factory CommandsClient(Dio dio, {String? baseUrl}) = _CommandsClient;

  @POST('/api/v4/commands')
  Future<Command> createCommand({
    @Body() required ApiV4CommandsRequestBody body,
  });

  @GET('/api/v4/commands')
  Future<List<Command>> listCommands({
    @Query('custom_only') bool? customOnly = false,
    @Query('team_id') String? teamId,
  });

  @GET('/api/v4/teams/{team_id}/commands/autocomplete')
  Future<List<Command>> listAutocompleteCommands({
    @Path('team_id') required String teamId,
  });

  @GET('/api/v4/teams/{team_id}/commands/autocomplete_suggestions')
  Future<List<AutocompleteSuggestion>> listCommandAutocompleteSuggestions({
    @Path('team_id') required String teamId,
    @Query('user_input') required String userInput,
    @Query('channel_id') String? channelId,
    @Query('root_id') String? rootId,
  });

  @POST('/api/v4/commands/execute')
  Future<CommandResponse> executeCommand({
    @Body() required ApiV4CommandsExecuteRequestBody body,
  });
}

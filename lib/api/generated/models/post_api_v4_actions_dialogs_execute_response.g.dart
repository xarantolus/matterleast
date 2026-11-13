// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_actions_dialogs_execute_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ActionsDialogsExecuteResponse
_$PostApiV4ActionsDialogsExecuteResponseFromJson(Map<String, dynamic> json) =>
    PostApiV4ActionsDialogsExecuteResponse(
      status: const LenientString().fromJson(json['status']),
      triggerId: const LenientString().fromJson(json['trigger_id']),
    );

Map<String, dynamic> _$PostApiV4ActionsDialogsExecuteResponseToJson(
  PostApiV4ActionsDialogsExecuteResponse instance,
) => <String, dynamic>{
  'status': const LenientString().toJson(instance.status),
  'trigger_id': const LenientString().toJson(instance.triggerId),
};

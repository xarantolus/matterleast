// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_actions_dialogs_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ActionsDialogsSubmitResponse
_$PostApiV4ActionsDialogsSubmitResponseFromJson(Map<String, dynamic> json) =>
    PostApiV4ActionsDialogsSubmitResponse(
      error: const LenientString().fromJson(json['error']),
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PostApiV4ActionsDialogsSubmitResponseToJson(
  PostApiV4ActionsDialogsSubmitResponse instance,
) => <String, dynamic>{
  'error': const LenientString().toJson(instance.error),
  'errors': instance.errors,
};

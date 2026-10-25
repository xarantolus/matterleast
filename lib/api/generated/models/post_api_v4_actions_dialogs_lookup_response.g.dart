// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_actions_dialogs_lookup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4ActionsDialogsLookupResponse
_$PostApiV4ActionsDialogsLookupResponseFromJson(Map<String, dynamic> json) =>
    PostApiV4ActionsDialogsLookupResponse(
      options: json['options'] == null
          ? const []
          : const LenientListOfOptions().fromJson(json['options']),
    );

Map<String, dynamic> _$PostApiV4ActionsDialogsLookupResponseToJson(
  PostApiV4ActionsDialogsLookupResponse instance,
) => <String, dynamic>{
  'options': const LenientListOfOptions().toJson(instance.options),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_search_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionSearchRequest _$ActionSearchRequestFromJson(Map<String, dynamic> json) =>
    ActionSearchRequest(
      actions: json['actions'] == null
          ? const []
          : const LenientStringList().fromJson(json['actions']),
      resource: const LenientAccessControlResource().fromJson(json['resource']),
      subject: const LenientActionSearchSubject().fromJson(json['subject']),
      page: const LenientActionSearchPage().fromJson(json['page']),
    );

Map<String, dynamic> _$ActionSearchRequestToJson(
  ActionSearchRequest instance,
) => <String, dynamic>{
  'resource': const LenientAccessControlResource().toJson(instance.resource),
  'actions': const LenientStringList().toJson(instance.actions),
  'subject': const LenientActionSearchSubject().toJson(instance.subject),
  'page': const LenientActionSearchPage().toJson(instance.page),
};

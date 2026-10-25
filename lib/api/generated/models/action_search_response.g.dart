// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionSearchResponse _$ActionSearchResponseFromJson(
  Map<String, dynamic> json,
) => ActionSearchResponse(
  results: json['results'] == null
      ? const []
      : const LenientListOfActionSearchResult().fromJson(json['results']),
  resource: const LenientAccessControlResource().fromJson(json['resource']),
  decisions: const LenientMapOfRenderPermissionDecision().fromJson(
    json['decisions'],
  ),
  page: const LenientActionSearchPage().fromJson(json['page']),
);

Map<String, dynamic> _$ActionSearchResponseToJson(
  ActionSearchResponse instance,
) => <String, dynamic>{
  'resource': const LenientAccessControlResource().toJson(instance.resource),
  'results': const LenientListOfActionSearchResult().toJson(instance.results),
  'decisions': const LenientMapOfRenderPermissionDecision().toJson(
    instance.decisions,
  ),
  'page': const LenientActionSearchPage().toJson(instance.page),
};

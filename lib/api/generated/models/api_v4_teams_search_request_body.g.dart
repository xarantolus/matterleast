// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_teams_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4TeamsSearchRequestBody _$ApiV4TeamsSearchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4TeamsSearchRequestBody(
  excludePolicyConstrained:
      json['exclude_policy_constrained'] as bool? ?? false,
  term: const LenientString().fromJson(json['term']),
  page: const LenientString().fromJson(json['page']),
  perPage: const LenientString().fromJson(json['per_page']),
  allowOpenInvite: const LenientBool().fromJson(json['allow_open_invite']),
  groupConstrained: const LenientBool().fromJson(json['group_constrained']),
);

Map<String, dynamic> _$ApiV4TeamsSearchRequestBodyToJson(
  ApiV4TeamsSearchRequestBody instance,
) => <String, dynamic>{
  'term': const LenientString().toJson(instance.term),
  'page': const LenientString().toJson(instance.page),
  'per_page': const LenientString().toJson(instance.perPage),
  'allow_open_invite': const LenientBool().toJson(instance.allowOpenInvite),
  'group_constrained': const LenientBool().toJson(instance.groupConstrained),
  'exclude_policy_constrained': instance.excludePolicyConstrained,
};

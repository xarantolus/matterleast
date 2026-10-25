// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsSearchRequestBody _$ApiV4ChannelsSearchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4ChannelsSearchRequestBody(
  term: json['term'] as String,
  teamIds: json['team_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['team_ids']),
  excludePolicyConstrained:
      json['exclude_policy_constrained'] as bool? ?? false,
  includeSearchById: json['include_search_by_id'] as bool? ?? false,
  excludeRemote: json['exclude_remote'] as bool? ?? false,
  notAssociatedToGroup: const LenientString().fromJson(
    json['not_associated_to_group'],
  ),
  excludeDefaultChannels: const LenientBool().fromJson(
    json['exclude_default_channels'],
  ),
  groupConstrained: const LenientBool().fromJson(json['group_constrained']),
  excludeGroupConstrained: const LenientBool().fromJson(
    json['exclude_group_constrained'],
  ),
  public: const LenientBool().fromJson(json['public']),
  private: const LenientBool().fromJson(json['private']),
  deleted: const LenientBool().fromJson(json['deleted']),
  page: const LenientString().fromJson(json['page']),
  perPage: const LenientString().fromJson(json['per_page']),
);

Map<String, dynamic> _$ApiV4ChannelsSearchRequestBodyToJson(
  ApiV4ChannelsSearchRequestBody instance,
) => <String, dynamic>{
  'term': instance.term,
  'not_associated_to_group': const LenientString().toJson(
    instance.notAssociatedToGroup,
  ),
  'exclude_default_channels': const LenientBool().toJson(
    instance.excludeDefaultChannels,
  ),
  'team_ids': const LenientStringList().toJson(instance.teamIds),
  'group_constrained': const LenientBool().toJson(instance.groupConstrained),
  'exclude_group_constrained': const LenientBool().toJson(
    instance.excludeGroupConstrained,
  ),
  'public': const LenientBool().toJson(instance.public),
  'private': const LenientBool().toJson(instance.private),
  'deleted': const LenientBool().toJson(instance.deleted),
  'page': const LenientString().toJson(instance.page),
  'per_page': const LenientString().toJson(instance.perPage),
  'exclude_policy_constrained': instance.excludePolicyConstrained,
  'include_search_by_id': instance.includeSearchById,
  'exclude_remote': instance.excludeRemote,
};

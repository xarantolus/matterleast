// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_search_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsSearchRequestBody {
  const ApiV4ChannelsSearchRequestBody({
    required this.term,
    this.teamIds = const [],
    this.excludePolicyConstrained = false,
    this.includeSearchById = false,
    this.excludeRemote = false,
    this.notAssociatedToGroup,
    this.excludeDefaultChannels,
    this.groupConstrained,
    this.excludeGroupConstrained,
    this.public,
    this.private,
    this.deleted,
    this.page,
    this.perPage,
  });

  factory ApiV4ChannelsSearchRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4ChannelsSearchRequestBodyFromJson(json);

  final String term;
  @LenientString()
  @JsonKey(name: 'not_associated_to_group')
  final String? notAssociatedToGroup;
  @LenientBool()
  @JsonKey(name: 'exclude_default_channels')
  final bool? excludeDefaultChannels;
  @LenientStringList()
  @JsonKey(name: 'team_ids')
  final List<String> teamIds;
  @LenientBool()
  @JsonKey(name: 'group_constrained')
  final bool? groupConstrained;
  @LenientBool()
  @JsonKey(name: 'exclude_group_constrained')
  final bool? excludeGroupConstrained;
  @LenientBool()
  final bool? public;
  @LenientBool()
  final bool? private;
  @LenientBool()
  final bool? deleted;
  @LenientString()
  final String? page;
  @LenientString()
  @JsonKey(name: 'per_page')
  final String? perPage;
  @JsonKey(name: 'exclude_policy_constrained')
  final bool excludePolicyConstrained;
  @JsonKey(name: 'include_search_by_id')
  final bool includeSearchById;
  @JsonKey(name: 'exclude_remote')
  final bool excludeRemote;

  Map<String, Object?> toJson() => _$ApiV4ChannelsSearchRequestBodyToJson(this);
}

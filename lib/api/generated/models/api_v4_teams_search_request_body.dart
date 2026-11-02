// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_teams_search_request_body.g.dart';

@JsonSerializable()
class ApiV4TeamsSearchRequestBody {
  const ApiV4TeamsSearchRequestBody({
    this.excludePolicyConstrained = false,
    this.term,
    this.page,
    this.perPage,
    this.allowOpenInvite,
    this.groupConstrained,
  });

  factory ApiV4TeamsSearchRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4TeamsSearchRequestBodyFromJson(json);

  @LenientString()
  final String? term;
  @LenientString()
  final String? page;
  @LenientString()
  @JsonKey(name: 'per_page')
  final String? perPage;
  @LenientBool()
  @JsonKey(name: 'allow_open_invite')
  final bool? allowOpenInvite;
  @LenientBool()
  @JsonKey(name: 'group_constrained')
  final bool? groupConstrained;
  @JsonKey(name: 'exclude_policy_constrained')
  final bool excludePolicyConstrained;

  Map<String, Object?> toJson() => _$ApiV4TeamsSearchRequestBodyToJson(this);
}

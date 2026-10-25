// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'channel_banner.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'api_v4_channels_channel_id_patch_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdPatchRequestBody {
  const ApiV4ChannelsChannelIdPatchRequestBody({
    this.name,
    this.displayName,
    this.purpose,
    this.header,
    this.groupConstrained,
    this.autotranslation,
    this.bannerInfo,
    this.managedCategoryName,
    this.defaultCategoryName,
  });

  factory ApiV4ChannelsChannelIdPatchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdPatchRequestBodyFromJson(json);

  @LenientString()
  final String? name;

  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;

  @LenientString()
  final String? purpose;

  @LenientString()
  final String? header;

  @LenientBool()
  @JsonKey(name: 'group_constrained')
  final bool? groupConstrained;

  @LenientBool()
  final bool? autotranslation;
  @LenientChannelBanner()
  @JsonKey(name: 'banner_info')
  final ChannelBanner? bannerInfo;

  @LenientString()
  @JsonKey(name: 'managed_category_name')
  final String? managedCategoryName;

  @LenientString()
  @JsonKey(name: 'default_category_name')
  final String? defaultCategoryName;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdPatchRequestBodyToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_channels_channel_id_patch_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4ChannelsChannelIdPatchRequestBody
_$ApiV4ChannelsChannelIdPatchRequestBodyFromJson(Map<String, dynamic> json) =>
    ApiV4ChannelsChannelIdPatchRequestBody(
      name: const LenientString().fromJson(json['name']),
      displayName: const LenientString().fromJson(json['display_name']),
      purpose: const LenientString().fromJson(json['purpose']),
      header: const LenientString().fromJson(json['header']),
      groupConstrained: const LenientBool().fromJson(json['group_constrained']),
      autotranslation: const LenientBool().fromJson(json['autotranslation']),
      bannerInfo: const LenientChannelBanner().fromJson(json['banner_info']),
      managedCategoryName: const LenientString().fromJson(
        json['managed_category_name'],
      ),
      defaultCategoryName: const LenientString().fromJson(
        json['default_category_name'],
      ),
    );

Map<String, dynamic> _$ApiV4ChannelsChannelIdPatchRequestBodyToJson(
  ApiV4ChannelsChannelIdPatchRequestBody instance,
) => <String, dynamic>{
  'name': const LenientString().toJson(instance.name),
  'display_name': const LenientString().toJson(instance.displayName),
  'purpose': const LenientString().toJson(instance.purpose),
  'header': const LenientString().toJson(instance.header),
  'group_constrained': const LenientBool().toJson(instance.groupConstrained),
  'autotranslation': const LenientBool().toJson(instance.autotranslation),
  'banner_info': const LenientChannelBanner().toJson(instance.bannerInfo),
  'managed_category_name': const LenientString().toJson(
    instance.managedCategoryName,
  ),
  'default_category_name': const LenientString().toJson(
    instance.defaultCategoryName,
  ),
};

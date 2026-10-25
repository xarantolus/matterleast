// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelBanner _$ChannelBannerFromJson(Map<String, dynamic> json) =>
    ChannelBanner(
      enabled: const LenientBool().fromJson(json['enabled']),
      text: const LenientString().fromJson(json['text']),
      backgroundColor: const LenientString().fromJson(json['background_color']),
    );

Map<String, dynamic> _$ChannelBannerToJson(
  ChannelBanner instance,
) => <String, dynamic>{
  'enabled': const LenientBool().toJson(instance.enabled),
  'text': const LenientString().toJson(instance.text),
  'background_color': const LenientString().toJson(instance.backgroundColor),
};

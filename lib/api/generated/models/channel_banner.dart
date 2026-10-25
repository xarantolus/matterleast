// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'channel_banner.g.dart';

@JsonSerializable()
class ChannelBanner {
  const ChannelBanner({this.enabled, this.text, this.backgroundColor});

  factory ChannelBanner.fromJson(Map<String, Object?> json) =>
      _$ChannelBannerFromJson(json);

  @LenientBool()
  final bool? enabled;

  @LenientString()
  final String? text;

  @LenientString()
  @JsonKey(name: 'background_color')
  final String? backgroundColor;

  Map<String, Object?> toJson() => _$ChannelBannerToJson(this);
}

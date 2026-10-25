// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_channels_channel_id_privacy_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdPrivacyRequestBody {
  const ApiV4ChannelsChannelIdPrivacyRequestBody({required this.privacy});

  factory ApiV4ChannelsChannelIdPrivacyRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdPrivacyRequestBodyFromJson(json);

  final String privacy;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdPrivacyRequestBodyToJson(this);
}

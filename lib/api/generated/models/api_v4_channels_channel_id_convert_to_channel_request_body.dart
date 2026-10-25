// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_channels_channel_id_convert_to_channel_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdConvertToChannelRequestBody {
  const ApiV4ChannelsChannelIdConvertToChannelRequestBody({
    required this.channelId,
    required this.teamId,
  });

  factory ApiV4ChannelsChannelIdConvertToChannelRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdConvertToChannelRequestBodyFromJson(json);

  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'team_id')
  final String teamId;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdConvertToChannelRequestBodyToJson(this);
}

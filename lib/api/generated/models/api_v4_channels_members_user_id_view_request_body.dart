// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_members_user_id_view_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsMembersUserIdViewRequestBody {
  const ApiV4ChannelsMembersUserIdViewRequestBody({
    required this.channelId,
    this.prevChannelId,
    this.collapsedThreadsSupported,
  });

  factory ApiV4ChannelsMembersUserIdViewRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsMembersUserIdViewRequestBodyFromJson(json);

  @JsonKey(name: 'channel_id')
  final String channelId;

  @LenientString()
  @JsonKey(name: 'prev_channel_id')
  final String? prevChannelId;
  @LenientBool()
  @JsonKey(name: 'collapsed_threads_supported')
  final bool? collapsedThreadsSupported;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsMembersUserIdViewRequestBodyToJson(this);
}

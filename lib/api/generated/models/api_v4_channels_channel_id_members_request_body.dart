// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_channel_id_members_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdMembersRequestBody {
  const ApiV4ChannelsChannelIdMembersRequestBody({
    this.userId,
    this.postRootId,
  });

  factory ApiV4ChannelsChannelIdMembersRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdMembersRequestBodyFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  @JsonKey(name: 'post_root_id')
  final String? postRootId;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdMembersRequestBodyToJson(this);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_channel_id_members_request_body2.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdMembersRequestBody2 {
  const ApiV4ChannelsChannelIdMembersRequestBody2({
    this.members = const [],
    this.channelAdmins = const [],
  });

  factory ApiV4ChannelsChannelIdMembersRequestBody2.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdMembersRequestBody2FromJson(json);

  @LenientStringList()
  final List<String> members;

  @JsonKey(name: 'channel_admins')
  final List<String>? channelAdmins;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdMembersRequestBody2ToJson(this);
}
